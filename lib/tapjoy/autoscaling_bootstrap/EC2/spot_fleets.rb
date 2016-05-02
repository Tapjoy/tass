module Tapjoy
  module AutoscalingBootstrap
    module EC2
      # Code specific to Launch Configs
      module SpotFleets
        class << self
          attr_accessor :request_id

          def request(config, userdata_dir)
            self.request_id = Tapjoy::AutoscalingBootstrap::AWS::EC2.request_spot_fleet(
              userdata_dir: userdata_dir, **config).spot_fleet_request_id
          end
        end
      end
    end
  end
end
