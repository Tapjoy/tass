module Tapjoy
  module AutoscalingBootstrap
    module AWS
    # This class contains AWS methods for EC2
      module EC2
        class << self
          def client
            @client ||= Aws::EC2::Client.new
          end

          def describe_security_groups(group)
            self.client.describe_security_groups(group_names: [group])
          end

          def create_security_group(group)
            self.client.create_security_group(group_name: group,
              description: "Security group for #{Tapjoy::AutoscalingBootstrap.scaler_name}")
          end

          def describe_instances_by_tag(config)
            self.client.describe_instances(filters: [
              {name: 'tag:Name', values: [config[:name]]},
              {name: 'instance-state-name', values: %w(running)}
              ])
          end

          def toggle_termination_protection(instance_id, state)
            client.modify_instance_attribute(
              instance_id: instance_id,
              attribute: 'disableApiTermination',
              value: state)
          end

          def terminate_instances(instance_ids)
            client.terminate_instances(instance_ids: instance_ids)
          end
        end
      end
    end
  end
end
