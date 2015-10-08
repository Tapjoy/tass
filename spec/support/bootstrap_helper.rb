require 'vcr'
require 'active_support/concern'

module BootstrapHelper
  extend ActiveSupport::Concern

  included do
    let(:util)                    { Tapjoy::AutoscalingBootstrap::Base.new }
    let(:cluster_name)            { 'tass-test' }
    let(:elb_name)                { 'test-elb' }
    let(:cluster_filename)        { 'spec/fixtures/config/clusters/test_cluster.yaml' }
    let(:opts)                    {
      {env: 'qa', filename: cluster_filename}
    }
    let(:facet_hash)              { util.load_yaml(cluster_filename) }
    let(:environment)             {
      util.configure_environment(opts[:filename], opts[:env])
    }
    let(:new_config)              { environment[0] }
    let(:aws_env)                 { environment[1] }
    let(:user_data)               { environment[2] }
    let(:groups)                  { util.get_security_groups(opts[:config_dir], opts[:env], new_config[:group]) }
    let(:zones)                    { new_config[:zones] }
    let(:security_groups)          { groups }

    before(:all) do
      @util = Tapjoy::AutoscalingBootstrap::Base.new
      @elb_name = 'test-elb'
      @cluster_filename = './spec/fixtures/config/clusters/test_cluster.yaml'
      @opts = {
        env:        'qa',
        filename:   @cluster_filename,
      }
      @environment = @util.configure_environment(
        @opts[:filename], @opts[:env])
      @elb_hash = {
        @elb_name => @environment.first[:default_elb_parameters].merge!(elb_port: 80)
      }
      @clobber_elb = true
      @zones = @environment.first[:zones]
      @security_groups = @environment[1]
    end

    before(:each) do
      Aws.config[:region] = new_config[:aws_region]
      Tapjoy::AutoscalingBootstrap.scaler_name = "#{cluster_name}-group"
      Tapjoy::AutoscalingBootstrap.config_name = "#{cluster_name}-config"
      Tapjoy::AutoscalingBootstrap.elb_name = @elb_name
    end
  end
end
