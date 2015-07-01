module Tapjoy
  module AutoscalingBootstrap
    module AWS
    # This class contains AWS methods for ELB
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
        end
      end
    end
  end
end
