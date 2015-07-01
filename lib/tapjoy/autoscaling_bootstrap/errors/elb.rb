module Tapjoy
  module AutoscalingBootstrap
    module Errors
      module ELB
        # Raise if we try to overwrite an unclobbered ELB
        class ClobberRequired < ArgumentError
          def initialize
            elb_name = Tapjoy::AutoscalingBootstrap.elb_name
            error = 'CLOBBER_ELB env var was not true, CREATE_ELB setting was ' \
            "true and ELB '#{elb_name}' exists so we are aborting."
            abort(error)
          end
        end

        # Raise if ELB Name is too long
        class NameTooLong < NameError
          def initialize
            elb_name = Tapjoy::AutoscalingBootstrap.elb_name
            error = "ELB Name too long: #{elb_name.length} characters. " \
            'Must be less than 32'
            abort(error)
          end
        end

        # Raise if NaE
        class NotAnELB < ArgumentError
          def initialize
            abort('CREATE_ELB specified without a name')
          end
        end

        # Raise if ELB port is missing
        class MissingPort < ArgumentError
          def initialize
            abort('ELB port must be specified')
          end
        end

        # Raise if ELB instance protocol is missing
        class MissingInstanceProtocol < ArgumentError
          def initialize
            abort('Instance protocol must be specified')
          end
        end
      end
    end
  end
end
