require_relative '../../spec_helper'

describe Tapjoy::AutoscalingBootstrap::LaunchConfiguration, :vcr do
  describe '#update' do
    let(:facet_hash)              { util.load_yaml(cluster_update_filename) }

    it 'updates launch configurations', launch_config: 'update' do
      expect{
        Tapjoy::AutoscalingBootstrap::LaunchConfiguration.new(**new_config, aws_env)
      }.to_not raise_error
    end
  end
end
