require 'spec_helper'

describe Tapjoy::AutoscalingBootstrap::Audit do
  describe '#new' do
    it 'audits a config file' do
      expect{Tapjoy::AutoscalingBootstrap::Audit.new(new_config)}.to_not raise_error
    end
  end
end