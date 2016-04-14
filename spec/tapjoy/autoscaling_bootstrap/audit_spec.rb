require 'spec_helper'

describe Tapjoy::AutoscalingBootstrap::Audit do
  describe '#new' do
    it 'audits a config file', :audit => 'print' do
      # Since we stub describe the tag formatting needs to be changed
      remote_config = new_config.merge(:tags => [{:resource_type=>"auto-scaling-group", :key=>"Name", :value=>"tass-test", :propagate_at_launch=>true}])
      allow(Tapjoy::AutoscalingBootstrap::AWS::Autoscaling::LaunchConfig).to receive(:describe).and_return(remote_config)
      expect{Tapjoy::AutoscalingBootstrap::Audit.new(new_config)}.to_not raise_error
    end
  end
end
