module Tapjoy
  module AutoscalingBootstrap
    # This module configures cloudwatch alarms
    module Cloudwatch
      class << self
        # Create autoscaling alarms
        def create_alarm(scale_alert)
          puts "Creating: #{scale_alert[:alarm]}"
          Tapjoy::AutoscalingBootstrap::AWS::Cloudwatch.put_metric_alarm(
            **scale_alert)
        end

        # Delete autoscaling alarms
        def delete_alarm(alarm)
          if self.alarm_exists(alarm)
            puts "Deleting alarm: #{alarm}"
            Tapjoy::AutoscalingBootstrap::AWS::Cloudwatch.delete_alarm(alarm)
          else
            STDERR.puts "'#{alarm}' doesn't exist. Skipping..."
          end
        end

        def alarm_exists(alarm)
          Tapjoy::AutoscalingBootstrap::AWS::Cloudwatch.describe_alarm(alarm).length > 0
        end
      end
    end
  end
end
