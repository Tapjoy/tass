module Tapjoy
  module AutoscalingBootstrap
    module AWS
    # This class contains AWS methods for ELB
      module Cloudwatch
        class << self
          def client
            @client ||= Aws::CloudWatch::Client.new
          end

          def put_metric_alarm(alarm:, comparison_operator:,
            evaluation_periods:, threshold:, actions:)
            self.client.put_metric_alarm(alarm_name: alarm,
              comparison_operator: comparison_operator,
              evaluation_periods: evaluation_periods,
              metric_name: 'CPUUtilization',
              namespace: 'AWS/EC2',
              period: 300,
              statistic: 'Average',
              threshold: threshold,
              alarm_actions: actions,
              dimensions: [
                {
                  name:'AutoScalingGroupName',
                  value: Tapjoy::AutoscalingBootstrap.scaler_name
                }
              ])
          end

          def describe_alarm(alarm)
            self.client.describe_alarms(alarm_names: [alarm])[0]
          end

          def delete_alarm(alarm)
            self.client.delete_alarms(alarm_names: [alarm])
          end
        end
      end
    end
  end
end
