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
require_relative 'autoscaling_bootstrap/ec2'

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

      def valid_env?(config_dir, env)
        env_list = supported_envs(config_dir)
        unless env_list.include?(env)
          Trollop.die :env, "Currently supported enviroments are #{env_list.join(',')}"
        end
      end

      def supported_envs(listing)
        envs = []
        Dir.entries(listing).each do |file|
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
      def generate_user_data(userdata_dir, bootstrap_script, config)

        ERB.new(
          File.new(File.join(userdata_dir, bootstrap_script)).read, nil, '-'
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
        unless File.readable?("#{config_dir}/#{env}.yaml")
          fail Tapjoy::AutoscalingBootstrap::Errors::InvalidEnvironment
        end

        security_groups = {security_groups: group.split(',')}
      end

      # Clean list of ELBs
      def elb_list(config)
        config[:elb].map(&:keys).flatten.join(',')
      end

      # Confirm config settings before running autoscaling code
      def confirm_config(keypair:, zones:, security_groups:, instance_type:,
        image_id:, iam_instance_profile:, prompt:, use_vpc: use_vpc,
        vpc_subnets: nil, has_elb: has_elb, config:, termination_policies:,
        **unused_values)

        puts '  Preparing to configure the following autoscaling group:'
        puts "  Launch Config:        #{Tapjoy::AutoscalingBootstrap.config_name}"
        puts "  Auto Scaler:          #{Tapjoy::AutoscalingBootstrap.scaler_name}"
        puts "  ELB:                  #{elb_list(config)}" if has_elb
        puts "  Key Pair:             #{keypair}"
        puts "  Zones:                #{zones.join(',')}"
        puts "  Groups:               #{security_groups.sort.join(',')}"
        puts "  Instance Type:        #{instance_type}"
        puts "  Image ID:             #{image_id}"
        puts "  IAM Role:             #{iam_instance_profile}"
        puts "  VPC Subnets:          #{vpc_subnets}" if use_vpc
        puts "  Termination Policies: #{termination_policies.sort.join(',')}"

        puts "\n\nNOTE! Continuing may have adverse effects if you end up " \
        "deleting an IN-USE PRODUCTION scaling group. Don't be dumb."
        return true unless prompt
        agree('Is this information correct? [y/n]')
      end

      # configure environment

      def configure_environment(opts)
        filename = opts[:filename]
        facet_file    = filename
        config_dir    = File.expand_path('../..', facet_file)
        userdata_dir  = "#{File.expand_path('../../..', facet_file)}/userdata"

        common_path   = File.join(config_dir, 'common')
        defaults_hash = self.load_yaml(File.join(common_path, 'defaults.yaml'))
        facet_hash    = self.load_yaml(facet_file)
        env = opts[:env] || facet_hash[:environment] || defaults_hash[:environment]
        Tapjoy::AutoscalingBootstrap.valid_env?(common_path, env)
        env_hash      = self.load_yaml(File.join(common_path, "#{env}.yaml"))

        new_config = defaults_hash.merge!(env_hash).merge(facet_hash)
        new_config[:config_dir] = config_dir
        new_config[:instance_ids] = opts[:instance_ids] if opts.key?(:instance_ids)
        aws_env = self.get_security_groups(common_path, env, new_config[:group])
        new_config.merge!(aws_env)

        new_config[:autoscale] = false unless new_config[:scaling_type].eql?('dynamic')
        new_config[:tags] << {Name: new_config[:name]}
        Tapjoy::AutoscalingBootstrap.scaler_name = "#{new_config[:name]}-group"
        Tapjoy::AutoscalingBootstrap.config_name = "#{new_config[:name]}-config"
        # If there's no ELB, then Not a ELB
        user_data = self.generate_user_data(userdata_dir,
          new_config[:bootstrap_script], new_config)

        [new_config, aws_env, user_data]
      end

      # Exponential backup
      def aws_wait(tries)
        backoff_sleep = 2 ** tries
        puts "Sleeping for #{backoff_sleep}..."
        sleep backoff_sleep
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
