module Tapjoy
  module AutoscalingBootstrap
    module Autoscaling
      # Class for Autoscaling policies
      class Policy

        # Initialize the class
        def initialize
          @scaler_name = Tapjoy::AutoscalingBootstrap.scaler_name
          @group       = Tapjoy::AutoscalingBootstrap.group
        end

        # Create autoscaling policy
        def create(policy, scale)
          return unless Tapjoy::AutoscalingBootstrap.group.exists
          Tapjoy::AutoscalingBootstrap::AWS::Autoscaling.put_scaling_policy(
            policy_name: policy, **scale)
        end

        # Delete scaling policies
        def delete(policy)
          return unless @group.exists

          if Tapjoy::AutoscalingBootstrap::AWS::Autoscaling.describe_policies(
            policy: policy)[0].length > 0

            puts "Deleting policy: #{policy}"
            Tapjoy::AutoscalingBootstrap::AWS::Autoscaling.delete_policy(
            policy: policy)
          else
            STDERR.puts "'#{policy}' doesn't exist. Skipping..."
          end
        end
      end
    end
  end
end
