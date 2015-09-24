module Tapjoy
  module AutoscalingBootstrap
    # This class configures elastic load balancers
    class ELB

      def initialize(elb_hash, clobber_elb, zones, security_groups)

        elb_config = build_config(elb_hash, zones, security_groups)
        check_valid_config(elb_config)

        if exists && clobber_elb
          delete
        elsif exists
          return
        end

        create(elb_config)
      end

      # Build config hash
      def build_config(elb_hash, zones, security_groups)
        elb_config = elb_hash[Tapjoy::AutoscalingBootstrap.elb_name]
        elb_config[:elb_protocol] ||= elb_config[:instance_protocol]
        elb_config[:elb_health_target] ||= "#{elb_config[:instance_protocol]}:#{elb_config[:instance_port]}/healthz"
        elb_config.merge!({zones: zones, groups: security_groups})
      end

      # Create load balancer
      def create(config)
        Tapjoy::AutoscalingBootstrap::AWS::ELB.create(**config)
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
