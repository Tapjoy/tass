module Tapjoy
  module AutoscalingBootstrap
    module Errors
      # Raise if we try to overwrite an unclobbered ASG
      class ClobberRequired < ArgumentError
        def initialize
          scaler_name = Tapjoy::AutoscalingBootstrap.scaler_name
          error = 'CLOBBER env var was not true, CREATE_AS_GROUP setting ' \
          "true and autoscale group '#{scaler_name}' exists so we are aborting."
          abort(error)
        end
      end

      # Raise if an invalid environment is specified
      class InvalidEnvironment < ArgumentError
        def initialize
          abort('Invalid environment specified')
        end
      end

      # Raise if an invalid launch configuration or autoscaling group
      # is specified
      class InvalidAutoscalingGroup < NoMethodError
        def initialize
          abort("ERROR: Specified autoscaling group doesn't exist")
        end
      end
    end
  end
end
