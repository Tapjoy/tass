module Tapjoy
  module AutoscalingBootstrap
    # This class is the central launching point for new autoscaling group creation
    class AutoscalingGroup
      # Initialize the class
      def create(opts, new_config, aws_env, user_data,

        # ELB Parameters
        elb_health_target: "#{new_config[:instance_protocol]}:#{new_config[:instance_port]}/healthz",
        elb_protocol: new_config[:instance_protocol],
        elb_name: "#{new_config[:name].gsub('_','-')}-discovery"
      )

        if new_config[:create_elb]
          new_config.merge!({
            elb_health_target: elb_health_target,
            elb_protocol:      elb_protocol,
            elb_name:          elb_name
          })

          Tapjoy::AutoscalingBootstrap::ELB.new.create(new_config, aws_env)
        else
          puts "\nNo ELB required"
        end

        Tapjoy::AutoscalingBootstrap::ConfigureAutoscalers.new(**new_config,
          aws_env: aws_env, user_data: user_data, misc_config: new_config)

        scaler_name = Tapjoy::AutoscalingBootstrap.scaler_name
        config_name = Tapjoy::AutoscalingBootstrap.config_name

        if new_config[:autoscale]
          new_config.merge!({
            alarm_low_scale:  "#{new_config[:human_name]} - Scale Down - Low CPU Utilization",
            alarm_high_scale: "#{new_config[:human_name]} - Scale Up - High CPU Utilization",
            policy_up:        "#{new_config[:name]}-up-policy",
            policy_down:      "#{new_config[:name]}-down-policy"
          })
          Tapjoy::AutoscalingBootstrap::Alerts::Scaling.new(new_config)
        end

        if new_config[:alerts]
          monitoring_alerts = Tapjoy::AutoscalingBootstrap::Alerts::Monitoring.new
          monitoring_alert_config = {
            alarm_low_alert:  "#{new_config[:human_name]} - ALARM - Extremely Low CPU Utilization",
            alarm_high_alert: "#{new_config[:human_name]} - ALARM - Extremely High CPU Utilization",
            notification: "#{new_config[:sns_base_arn]}:General-NOC-Notifications"
          }
          monitoring_alerts.create(**monitoring_alert_config)
        end

        puts "\n\nCreated -- "
        puts "Autoscaling Group: #{scaler_name}"
        puts "Launch Config:     #{config_name}"
        puts 'Instance Count:    0'
      end
    end
  end
end
