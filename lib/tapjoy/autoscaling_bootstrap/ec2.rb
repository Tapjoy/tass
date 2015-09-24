module Tapjoy
  module AutoscalingBootstrap
    # This class contains tass methods for EC2
    module EC2
      class << self
        def count_static_instances(config)
          find_static_instances(config).length
        end

        def enable_termination_protection(instance_id)
          Tapjoy::AutoscalingBootstrap::AWS::EC2.toggle_termination_protection(instance_id, 'true')
        end

        def disable_termination_protection(instance_id)
          Tapjoy::AutoscalingBootstrap::AWS::EC2.toggle_termination_protection(instance_id, 'false')
        end

        private
        def find_static_instances(config)
          response = Tapjoy::AutoscalingBootstrap::AWS::EC2.describe_instances_by_tag(config)
          response.reservations
        end
      end
    end
  end
end
