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

            def resize(min: 0, max: 0, desired:0)
              self.client.update_auto_scaling_group(
                auto_scaling_group_name: Tapjoy::AutoscalingBootstrap.scaler_name,
                min_size: min, max_size: max, desired_capacity: desired)
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

            def detach
              self.client.detach_instances(
                instance_ids: describe.instances.map(&:instance_id),
                auto_scaling_group_name: Tapjoy::AutoscalingBootstrap.scaler_name,
                should_decrement_desired_capacity: true,
              )
            end

            def create(zones:, health_check_type: nil, placement_group: nil, tags:,
              vpc_subnets: nil, termination_policies: , **unused_values)

              group_hash = {
                auto_scaling_group_name: Tapjoy::AutoscalingBootstrap.scaler_name,
                availability_zones: zones,
                launch_configuration_name: Tapjoy::AutoscalingBootstrap.config_name,
                min_size: 0, max_size: 0, desired_capacity: 0,
                termination_policies: termination_policies,
                vpc_zone_identifier: vpc_subnets,
                placement_group: placement_group,
                tags: Tapjoy::AutoscalingBootstrap::Autoscaling::Group.new.generate_tags(tags)
              }

              self.client.create_auto_scaling_group(**group_hash)
            end

            def update_launch_config(scaler_name)
              self.client.update_auto_scaling_group(
                auto_scaling_group_name: scaler_name,
                launch_configuration_name: Tapjoy::AutoscalingBootstrap.config_name,
              )
            end

            def attach_elb(elb_list)
              self.client.attach_load_balancers({
                auto_scaling_group_name: Tapjoy::AutoscalingBootstrap.scaler_name,
                load_balancer_names: elb_list.split(','),
              })
            end
          end
        end
      end
    end
  end
end
