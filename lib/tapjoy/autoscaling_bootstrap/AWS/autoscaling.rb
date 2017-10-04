module Tapjoy
  module AutoscalingBootstrap
    module AWS
    # This class contains AWS methods for ELB
      module Autoscaling
        class << self
          def client
            @client ||= Aws::AutoScaling::Client.new
          end

          def put_notification_configuration(sns_base_arn:, **unused_values)
            self.client.put_notification_configuration(
              auto_scaling_group_name: Tapjoy::AutoscalingBootstrap.scaler_name,
              topic_arn: "#{sns_base_arn}:InstanceTerminated",
              notification_types: ['autoscaling:EC2_INSTANCE_TERMINATE']
            )
          end

          ## TODO Call put_scaling_policy based on whether content of YAML and describe_policies are different

          def put_scaling_policy(policy_name: policy, scaling_adjustment:,
            cooldown:, **unused_values)

            self.client.put_scaling_policy(policy_name: policy_name,
              auto_scaling_group_name: Tapjoy::AutoscalingBootstrap.scaler_name,
              scaling_adjustment: scaling_adjustment,
              cooldown: cooldown,
              adjustment_type: 'ChangeInCapacity'
            )[0]
          end

          def describe_policies(policy:)
            self.client.describe_policies(
              auto_scaling_group_name: Tapjoy::AutoscalingBootstrap.scaler_name,
              policy_names: [policy])
          end

          def delete_policy(policy:)
            self.client.delete_policy(
              auto_scaling_group_name: Tapjoy::AutoscalingBootstrap.scaler_name,
              policy_name: policy)
          end
        end
      end
    end
  end
end
