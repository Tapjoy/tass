module Tapjoy
  module AutoscalingBootstrap
    # This class configures elastic load balancers
    class ELB
      # Initialize the class
      def initialize
      end

      # Create load balancer
      def create(config, aws_env)

        check_valid_config(config)
        delete if exists
        Tapjoy::AutoscalingBootstrap::AWS::ELB.create(**config, **aws_env)
        health_check(config)
      end

      # Configure health check
      def health_check(config)
        abort('Target must be specified') if config[:elb_health_target].nil?

        begin
          Tapjoy::AutoscalingBootstrap::AWS::ELB.health_check(**config)
        rescue Aws::ElasticLoadBalancing::Errors::ValidationError => err
          abort("Fatal! Invalid ELB Configuration: #{err}")
        end
      end

      # Check if ELB exists
      def exists
        begin
          Tapjoy::AutoscalingBootstrap::AWS::ELB.describe
          return true
        rescue Aws::ElasticLoadBalancing::Errors::LoadBalancerNotFound => err
          STDERR.puts "Warning: #{err}"
          return false
        end
      end

      # Delete ELB
      def delete
        puts 'Removing existing ELB'
        Tapjoy::AutoscalingBootstrap::AWS::ELB.delete
      end

      private
      # Check configuration
      def check_valid_config(config)
        fail Tapjoy::AutoscalingBootstrap::Errors::ELB::NameTooLong if Tapjoy::AutoscalingBootstrap.elb_name.length > 32
        fail Tapjoy::AutoscalingBootstrap::Errors::ELB::NotAnELB if Tapjoy::AutoscalingBootstrap.elb_name.eql?'NaE'
        fail Tapjoy::AutoscalingBootstrap::Errors::ELB::MissingPort if config[:elb_port].nil?
        fail Tapjoy::AutoscalingBootstrap::Errors::ELB::MissingInstanceProtocol if config[:instance_protocol].nil?
      end
    end
  end
end
