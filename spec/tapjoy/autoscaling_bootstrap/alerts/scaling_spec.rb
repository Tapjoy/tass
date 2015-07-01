require_relative '../../../spec_helper'

describe Tapjoy::AutoscalingBootstrap::Alerts::Scaling, :vcr do
  let (:config) { new_config.merge({
      alarm_low_scale:  "#{new_config[:human_name]} - Scale Down - Low CPU Utilization",
      alarm_high_scale: "#{new_config[:human_name]} - Scale Up - High CPU Utilization",
      policy_up:        "#{new_config[:name]}-up-policy",
      policy_down:      "#{new_config[:name]}-down-policy"
    })}

  it 'creates scaling alerts', :alerts => 'create_alarm' do
    expect{Tapjoy::AutoscalingBootstrap::Alerts::Scaling.new(
      **config,
    )}.to_not raise_error
  end

  it 'deletes scaling alerts', :alerts => 'delete_alarm' do
    expect{Tapjoy::AutoscalingBootstrap::Cloudwatch.delete_alarm(
      config[:alarm_high_scale]
    )}.to_not raise_error
    expect{Tapjoy::AutoscalingBootstrap::Cloudwatch.delete_alarm(
      config[:alarm_low_scale]
    )}.to_not raise_error
  end
end
