module Tapjoy
  module AutoscalingBootstrap
    module AWS
      module Cloudformation
        class << self
          def client
            @client ||= Aws::CloudFormation::Client.new
          end

          def create_stack(**argument_hash)
            ## TODO: get this working
            # self.client.create_stack(**argument_hash)
          end

          def update_stack(**argument_hash)
            ## TODO: get this working
            # self.client.update_stack(**argument_hash)
          end

          def validate_template(**argument_hash)
            ## TODO: get this working
            # self.client.validate_template(**argument_hash)
          end
        end
      end
    end
  end
end
