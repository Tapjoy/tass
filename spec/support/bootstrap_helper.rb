require 'vcr'
require 'active_support/concern'

module BootstrapHelper
  extend ActiveSupport::Concern

  included do
    let(:util)                    { Tapjoy::AutoscalingBootstrap::Base.new }
    let(:cluster_name)            { 'asb-test' }
    let(:elb_name)                { 'test-elb' }
    let(:cluster_filename)        { 'test_cluster.yaml' }
    # let(:cluster_update_filename) { 'spec/fixtures/test_cluster_update.yaml' }
    let(:opts)                    {
      {env:        'qa',
       filename:   cluster_filename,
       config_dir: 'spec/fixtures/'}
    }
    let(:defaults_hash)           { util.load_yaml("#{opts[:config_dir]}/defaults.yaml") }
    let(:facet_hash)              { util.load_yaml(cluster_filename) }
    let(:common_hash)             { util.load_yaml("#{opts[:config_dir]}/qa.yaml") }
    let(:environment)             {
      util.configure_environment(
      opts[:filename],
      opts[:env],
      opts[:config_dir])
    }
    let(:new_config)              { environment.first }
    let(:aws_env)                 { environment[1] }
    let(:user_data)               { util.generate_user_data(config_dir:opts[:config_dir], **new_config) }
    let(:groups)                  { util.get_security_groups(opts[:env], new_config[:group]) }

    before(:each) do
      Aws.config[:region] = new_config[:aws_region]
      Tapjoy::AutoscalingBootstrap.scaler_name = "#{cluster_name}-group"
      Tapjoy::AutoscalingBootstrap.config_name = "#{cluster_name}-config"
      Tapjoy::AutoscalingBootstrap.elb_name = elb_name
    end
  end
end
