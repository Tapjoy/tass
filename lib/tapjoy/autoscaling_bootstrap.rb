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
        fail Tapjoy::AutoscalingBootstrap::Errors::ELB::ClobberRequired if check_elb_clobber(**opts, **config)
        puts "We don't need to clobber"
      end

      # Check autoscaling clobber
      def check_as_clobber(create_as_group:, clobber_as:, **unused_values)
        create_as_group && Tapjoy::AutoscalingBootstrap.group.exists && !clobber_as
      end

      # Check ELB clobber
      def check_elb_clobber(create_elb:, clobber_elb:, **unused_values)
        elb = Tapjoy::AutoscalingBootstrap::ELB.new
        create_elb && elb.exists && !clobber_elb
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

        elb_name = Tapjoy::AutoscalingBootstrap.elb_name

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
      def configure_environment(filename, env, config_dir)
        defaults_hash = self.load_yaml("#{config_dir}/config/common/defaults.yaml")
        facet_hash    = self.load_yaml("#{config_dir}/config/clusters/#{filename}")
        env_hash      = self.load_yaml("#{config_dir}/config/common/#{env}.yaml")

        new_config = defaults_hash.merge!(env_hash).merge(facet_hash)
        new_config[:config_dir] = config_dir
        aws_env = self.get_security_groups(config_dir, env, new_config[:group])

        Tapjoy::AutoscalingBootstrap.scaler_name = "#{new_config[:name]}-group"
        Tapjoy::AutoscalingBootstrap.config_name = "#{new_config[:name]}-config"
        # If there's no ELB, then Not a ELB
        puts new_config[:elb_name]
        Tapjoy::AutoscalingBootstrap.elb_name = new_config[:elb_name] || 'NaE'
        Tapjoy::AutoscalingBootstrap.create_elb = new_config[:create_elb]
        user_data = self.generate_user_data(new_config)
        return new_config, aws_env, user_data
      end

      # Exponential backup
      def aws_wait(tries)
        puts "Sleeping for #{2 ** tries}..."
        sleep 2 ** tries
      end
    end
  end
end
