module Tapjoy
  module AutoscalingBootstrap
    module Alerts
      # Class to handle monitoring alerts
      class Monitoring
        # Create monitoring alerts
        def create(alarm_high_alert:, alarm_low_alert:, notification:)

          high_alert = {
            alarm:               alarm_high_alert,
            comparison_operator: 'GreaterThanOrEqualToThreshold',
            evaluation_periods:  1,
            threshold:           90,
            actions:             [notification]
          }

          low_alert = {
            alarm:               alarm_low_alert,
            comparison_operator: 'LessThanOrEqualToThreshold',
            evaluation_periods:  1,
            threshold:           35,
            actions:             [notification]
          }
          puts 'Clearing out original CloudWatch alarms'
          Tapjoy::AutoscalingBootstrap::Cloudwatch.delete_alarm(alarm_high_alert)
          Tapjoy::AutoscalingBootstrap::Cloudwatch.delete_alarm(alarm_low_alert)

          puts 'Creating new CloudWatch Alarms'
          Tapjoy::AutoscalingBootstrap::Cloudwatch.create_alarm(high_alert)
          puts "\n"

          Tapjoy::AutoscalingBootstrap::Cloudwatch.create_alarm(low_alert)
          puts "\n"
        end
      end
    end
  end
end
