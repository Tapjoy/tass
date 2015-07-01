module Tapjoy
  module AutoscalingBootstrap
    module Alerts
      # Class to handle scaling alerts
      class Scaling
        # Initialize the class
        def initialize(config)
          @policy = Tapjoy::AutoscalingBootstrap.policy

          scale_up, scale_down = prepare(**config)

          create(config[:policy_up], scale_up)
          create(config[:policy_down], scale_down)
        end

        # Prepare scaling alerts
        def prepare(alarm_high_scale:, alarm_low_scale:, policy_up:,
          policy_down:, scale_up_scaling_adjustment:, scale_up_cooldown:,
          scale_up_threshold:, scale_down_scaling_adjustment:,
          scale_down_cooldown:, scale_down_threshold:, **unused_values)

          puts 'Creating autoscale alerts and policies'

          puts 'Clearing out original CloudWatch alarms'
          Tapjoy::AutoscalingBootstrap::Cloudwatch.delete_alarm(alarm_high_scale)
          Tapjoy::AutoscalingBootstrap::Cloudwatch.delete_alarm(alarm_low_scale)
          puts "\n"

          puts 'Clearing out original scaling policies'
          @policy.delete(policy_up)
          @policy.delete(policy_down)
          puts "\n"

          puts 'Configuring autoscaling...'
          scale_up = {
            scaling_adjustment:          scale_up_scaling_adjustment,
            cooldown:                    scale_up_cooldown,
            threshold:                   scale_up_threshold,
            alarm:                       alarm_high_scale,
            comparison_operator:         'GreaterThanOrEqualToThreshold'
          }

          scale_down = {
            scaling_adjustment:          scale_down_scaling_adjustment,
            cooldown:                    scale_down_cooldown,
            threshold:                   scale_down_threshold,
            alarm:                       alarm_low_scale,
            comparison_operator:         'LessThanOrEqualToThreshold'
          }

          return scale_up, scale_down
        end

        # Create alerts for autoscaling
        def create(policy, scale)

          puts "Creating scale policy: #{policy}"
          scale_policy = @policy.create(policy,
          **scale)

          scale_alert = {
            alarm:               scale[:alarm],
            comparison_operator: scale[:comparison_operator],
            evaluation_periods:  3,
            threshold:           scale[:threshold],
            actions:             [scale_policy]
          }

          puts "Creating alarms for scale policy: #{scale_policy}"
          Tapjoy::AutoscalingBootstrap::Cloudwatch.create_alarm(scale_alert)
        end
      end
    end
  end
end
