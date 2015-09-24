require 'aws-sdk-core'
require 'highline/import'
require 'base64'
require 'yaml'
require 'trollop'
require 'erb'
require 'hashdiff'

# relative requires
require_relative 'autoscaling_bootstrap/elb'
require_relative 'autoscaling_bootstrap/autoscaling'
require_relative 'autoscaling_bootstrap/autoscaling/config'
require_relative 'autoscaling_bootstrap/autoscaling/policy'
require_relative 'autoscaling_bootstrap/autoscaling/group'
require_relative 'autoscaling_bootstrap/cloudwatch'
require_relative 'autoscaling_bootstrap/configure_autoscaler'
require_relative 'autoscaling_bootstrap/errors'
require_relative 'autoscaling_bootstrap/errors/elb'
require_relative 'autoscaling_bootstrap/alerts'
require_relative 'autoscaling_bootstrap/alerts/scaling'
require_relative 'autoscaling_bootstrap/alerts/monitoring'
require_relative 'autoscaling_bootstrap/aws'
require_relative 'autoscaling_bootstrap/AWS/elb'
require_relative 'autoscaling_bootstrap/AWS/ec2'
require_relative 'autoscaling_bootstrap/AWS/cloudwatch'
require_relative 'autoscaling_bootstrap/AWS/autoscaling'
require_relative 'autoscaling_bootstrap/AWS/Autoscaling/group'
require_relative 'autoscaling_bootstrap/AWS/Autoscaling/launch_config'
require_relative 'autoscaling_bootstrap/autoscaling_group'
require_relative 'autoscaling_bootstrap/launch_configuration'
require_relative 'autoscaling_bootstrap/version'
require_relative 'autoscaling_bootstrap/audit'

module Tapjoy
  # Module for Autoscaling Bootstrap
  module AutoscalingBootstrap
    # This class is meant for class and instances variables used throughout
    # the application.
    class << self
      attr_accessor :scaler_name, :config_name, :create_elb
      attr_reader :elb_name

      # If you're using AutoscalingBootstrap to create a new ELB, that name goes here
      def elb_name=(str)
        @elb_name = str
      end

      # If you're using AutoscalingBootstrap to join to a list of existing ELBs, that array
      # goes here. This list can include or not include the provided elb_name, the
      # array + a custom elb_name will be uniq-ed before being passed to Amazon
      def elb_list=(list)
        @elb_list = list
      end

      def elb_list
        @elb_list ||= []
      end

      # This is the list of elbs passed to the autoscaling configuration. It will include
      # the created elb, as well as the specific list of elbs to join. It will call uniq
      # on the list in case you accidentally specify the same elb twice
      def elbs_to_join
        (elb_list + [Tapjoy::AutoscalingBootstrap.elb_name]).uniq
      end

      def policy
        @policy = Tapjoy::AutoscalingBootstrap::Autoscaling::Policy.new
      end

      def group
        @group = Tapjoy::AutoscalingBootstrap::Autoscaling::Group.new
      end

      def config
        @config = Tapjoy::AutoscalingBootstrap::Autoscaling::Config.new
      end

      def cloudwatch
        @cloudwatch = Tapjoy::AutoscalingBootstrap::CloudWatch.new
      end

      def config_dir
        @config_dir ||= ENV['TASS_CONFIG_DIR'] || "#{ENV['HOME']}/.tass"
      end

      def is_valid_env?(config_dir, env)
        env_list = self.supported_envs(config_dir)
        puts config_dir
        unless env_list.include?(env)
          Trollop.die :env, "Currently supported enviroments are #{env_list.join(',')}"
        end
      end

      def supported_envs(listing)
        envs = []
        Dir.entries("#{listing}/config/common").each do |file|
          next unless file.end_with?('yaml')
          next if file.start_with?('defaults')
          envs << file.chomp!('.yaml')
        end
        envs
      end
    end

    # Base class for generic methods used throughout the gem
    class Base
      # Confirm that yaml is readable and then convert to hash
      def load_yaml(filename)
        abort("ERROR: '#{filename}' is not readable") unless File.readable?(filename)
        Hash[YAML.load_file(filename)]
      end

      # Using variables passed in, generate user data file
      def generate_user_data(config)

        ERB.new(
          File.new("#{config[:config_dir]}/userdata/#{config[:bootstrap_script]}").read,nil,'-'
        ).result(binding)
      end

      # Check if we allow clobbering and need to clobber
      def check_clobber(opts, config)
        fail Tapjoy::AutoscalingBootstrap::Errors::ClobberRequired if check_as_clobber(**opts, **config)
        puts "We don't need to clobber"
      end

      # Check autoscaling clobber
      def check_as_clobber(create_as_group:, clobber_as:, **unused_values)
        create_as_group && Tapjoy::AutoscalingBootstrap.group.exists && !clobber_as
      end

      # Get AWS Environment
      def get_security_groups(config_dir, env, group)

        # Check environment file
        unless File.readable?("#{config_dir}/config/common/#{env}.yaml")
          fail Tapjoy::AutoscalingBootstrap::Errors::InvalidEnvironment
        end

        security_groups = {security_groups: group.split(',')}
      end

      # Confirm config settings before running autoscaling code
      def confirm_config(keypair:, zones:, security_groups:, instance_type:,
        image_id:, iam_instance_profile:, prompt:, use_vpc: use_vpc,
        vpc_subnets: nil, **unused_values)

        puts '  Preparing to configure the following autoscaling group:'
        puts "  Launch Config:  #{Tapjoy::AutoscalingBootstrap.config_name}"
        puts "  Auto Scaler:    #{Tapjoy::AutoscalingBootstrap.scaler_name}"
        puts "  ELB:            #{elb_name}" unless elb_name.eql? 'NaE'
        puts "  Key Pair:       #{keypair}"
        puts "  Zones:          #{zones.join(',')}"
        puts "  Groups:         #{security_groups.sort.join(',')}"
        puts "  Instance Type:  #{instance_type}"
        puts "  Image ID:       #{image_id}"
        puts "  IAM Role:       #{iam_instance_profile}"
        puts "  VPC Subnets:    #{vpc_subnets}" if use_vpc

        puts "\n\nNOTE! Continuing may have adverse effects if you end up " \
        "deleting an IN-USE PRODUCTION scaling group. Don't be dumb."
        return true unless prompt
        agree('Is this information correct? [y/n]')
      end

      # configure environment

      def configure_environment(filename, env=nil, config_dir)
        if filename.include?(File::SEPARATOR)
          facet_file    = filename
          config_dir   = File.expand_path('../../..', facet_file)
        else
          facet_file    = File.join(config_dir, 'config', 'clusters', filename)
        end

        common_path   = File.join(config_dir, 'config', 'common')
        defaults_hash = self.load_yaml(File.join(common_path, 'defaults.yaml'))
        facet_hash    = self.load_yaml(facet_file)
        env         ||= facet_hash[:environment]
        env         ||= defaults_hash[:environment]
        Tapjoy::AutoscalingBootstrap.is_valid_env?(config_dir, env)
        env_hash      = self.load_yaml(File.join(common_path, "#{env}.yaml"))

        new_config = defaults_hash.merge!(env_hash).merge(facet_hash)
        new_config[:config_dir] = config_dir
        aws_env = self.get_security_groups(config_dir, env, new_config[:group])
        new_config.merge!(aws_env)

        Tapjoy::AutoscalingBootstrap.scaler_name = "#{new_config[:name]}-group"
        Tapjoy::AutoscalingBootstrap.config_name = "#{new_config[:name]}-config"
        # If there's no ELB, then Not a ELB
        user_data = self.generate_user_data(new_config)
        return new_config, aws_env, user_data
      end

      # Exponential backup
      def aws_wait(tries)
        puts "Sleeping for #{2 ** tries}..."
        sleep 2 ** tries
      end

      # Check if security group exists and create it if it does not
      def sec_group_exists(groups)
        groups.each do |group|
          begin
            puts "Verifying #{group} exists..."
            group = Tapjoy::AutoscalingBootstrap::AWS::EC2.describe_security_groups(group)
          rescue Aws::EC2::Errors::InvalidGroupNotFound => err
            STDERR.puts "Warning: #{err}"
            puts "Creating #{group} for #{Tapjoy::AutoscalingBootstrap.scaler_name}"
            Tapjoy::AutoscalingBootstrap::AWS::EC2.create_security_group(group)
          end
        end
      end
    end
  end
end
