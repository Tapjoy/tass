require_relative '../../../spec_helper'

describe Tapjoy::AutoscalingBootstrap::Alerts::Monitoring, :vcr do
  it 'creates monitoring alerts', :alerts => 'monitoring' do
    monitoring_alerts = Tapjoy::AutoscalingBootstrap::Alerts::Monitoring.new
    monitoring_alert_config = {
      alarm_low_alert:  "#{new_config[:human_name]} - ALARM - Extremely Low CPU Utilization",
      alarm_high_alert: "#{new_config[:human_name]} - ALARM - Extremely High CPU Utilization",
      notification:     "#{new_config[:sns_base_arn]}:General-NOC-Notifications"
    }

    expect{monitoring_alerts.create(**monitoring_alert_config)}.to_not raise_error
  end
end
