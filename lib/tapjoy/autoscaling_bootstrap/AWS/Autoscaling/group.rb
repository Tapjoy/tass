module Tapjoy
  module AutoscalingBootstrap
    module AWS
      module Autoscaling
        # This module includes autoscaling group calls to AWS
        module Group
          class << self
            def client
              @client ||= Tapjoy::AutoscalingBootstrap::AWS::Autoscaling.client
            end

            def resize(min_size: 0, max_size: 0, desired_capacity:0)
              self.client.update_auto_scaling_group(
                auto_scaling_group_name: Tapjoy::AutoscalingBootstrap.scaler_name,
                min_size: min_size, max_size: max_size,
                desired_capacity: desired_capacity)
            end

            def delete(force_delete: true)
              self.client.delete_auto_scaling_group(
              auto_scaling_group_name: Tapjoy::AutoscalingBootstrap.scaler_name,
              force_delete: force_delete)
            end

            def describe
              self.client.describe_auto_scaling_groups(
                auto_scaling_group_names: [
                  Tapjoy::AutoscalingBootstrap.scaler_name
                ]
              )[0][0]
            end

            def create(zones:, health_check_type: nil, tags:,
              vpc_subnets: nil, create_elb:, **unused_values)

              group_hash = {
                auto_scaling_group_name: Tapjoy::AutoscalingBootstrap.scaler_name,
                availability_zones: zones,
                launch_configuration_name: Tapjoy::AutoscalingBootstrap.config_name,
                min_size: 0, max_size: 0, desired_capacity: 0,
                termination_policies: ['OldestInstance'],
                vpc_zone_identifier: vpc_subnets,
                tags: Tapjoy::AutoscalingBootstrap::Autoscaling::Group.new.generate_tags(tags)
              }

              if create_elb
                group_hash.merge!({
                  load_balancer_names: [Tapjoy::AutoscalingBootstrap.elb_name],
                  health_check_type: health_check_type,
                  health_check_grace_period: 300,
                  })
              end

              self.client.create_auto_scaling_group(**group_hash)
            end
          end
        end
      end
    end
  end
end
