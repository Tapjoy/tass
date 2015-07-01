module Tapjoy
  module AutoscalingBootstrap
    module AWS
    # This class contains AWS methods for ELB
      module ELB
        class << self
          def client
            @client ||= Aws::ElasticLoadBalancing::Client.new
          end

          # Creates ELB
          def create(elb_protocol:, elb_port:, instance_protocol:,
            instance_port:, zones:, **unused_values)
            self.client.create_load_balancer(
              load_balancer_name: Tapjoy::AutoscalingBootstrap.elb_name,
              listeners: [
                { protocol: elb_protocol, load_balancer_port: elb_port,
                  instance_protocol: instance_protocol,
                  instance_port: instance_port
                }
              ],
              availability_zones: zones)
          end

          # Configures health check in AWS
          def health_check(elb_health_target:, elb_health_interval:,
            elb_health_timeout:, elb_unhealthy_threshold:,
            elb_healthy_threshold:, **unused_values)

            self.client.configure_health_check(
              load_balancer_name: Tapjoy::AutoscalingBootstrap.elb_name,
              health_check: {
                target: elb_health_target,
                interval: elb_health_interval,
                timeout: elb_health_timeout,
                unhealthy_threshold: elb_unhealthy_threshold,
                healthy_threshold: elb_healthy_threshold
              })
          end

          # Deletes existing ELB
          def delete
            self.client.delete_load_balancer(
              load_balancer_name: Tapjoy::AutoscalingBootstrap.elb_name)
          end

          def describe
            self.client.describe_load_balancers(
              load_balancer_names: [Tapjoy::AutoscalingBootstrap.elb_name])
          end
        end
      end
    end
  end
end
