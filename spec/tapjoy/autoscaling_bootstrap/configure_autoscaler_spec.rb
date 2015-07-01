require_relative '../../spec_helper'

describe Tapjoy::AutoscalingBootstrap::ConfigureAutoscalers, :vcr do
  describe '#new' do
    let(:unclobbered_opts) { opts.merge({:clobber_as => false}) }

    it 'unclobbered asg', :unclobbered => 'asg' do
      expect{
        Tapjoy::AutoscalingBootstrap::ConfigureAutoscalers.new(**new_config,
          aws_env: aws_env, clobber: unclobbered_opts[:clobber_as],
          clobber_elb: unclobbered_opts[:clobber_elb])
      }.to raise_error {Tapjoy::AutoscalingBootstrap::Errors::ClobberRequired}
    end
  end
end
