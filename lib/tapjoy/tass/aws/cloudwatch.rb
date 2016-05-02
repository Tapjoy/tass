module Tapjoy
  module TASS
    module AWS
      # This module configures cloudwatch alarms
      module Cloudwatch
        class << self
          # Create autoscaling alarms
          def create_spot_fleet_alarm(config)
            # puts "Creating: #{scale_alert[:alarm]}"
            tf_file = open(
              File.join(Tapjoy::AutoscalingBootstrap.terraform_path,
                        'cloudwatch.tf'), 'w+')
            tf_file.write(
              ERB.new(File.new(template_file).read, nil, '-').result(binding)
            )
            tf_file.close
          end

          private

          def template_file
            @template_file ||= File.join(
              Tapjoy::AutoscalingBootstrap.template_dir, 'cloudwatch.tf.erb')
          end

          # @TODO: Move this to base class

        end
      end
    end
  end
end
