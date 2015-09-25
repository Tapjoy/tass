require 'vcr'
require 'active_support/concern'

module BootstrapHelper
  extend ActiveSupport::Concern

  included do
    let(:util)                    { Tapjoy::AutoscalingBootstrap::Base.new }
    let(:cluster_name)            { 'tass-test' }
    let(:elb_name)                { 'test-elb' }
    let(:cluster_filename)        { 'test_cluster.yaml' }
    # let(:cluster_update_filename) { 'spec/fixtures/test_cluster_update.yaml' }
    let(:opts)                    {
      {env:        'qa',
       filename:   cluster_filename,
       config_dir: 'spec/fixtures/'}
    }
    let(:defaults_hash)           { util.load_yaml("#{opts[:config_dir]}/common/defaults.yaml") }
    let(:facet_hash)              { util.load_yaml(cluster_filename) }
    # let(:facet_hash)              { util.load_yaml("#{opts[:config_dir]}/clusters/test_cluster.yaml") }
    let(:common_hash)             { util.load_yaml("#{opts[:config_dir]}/common/qa.yaml") }
    let(:environment)             {
      util.configure_environment(
      opts[:filename],
      opts[:env],
      opts[:config_dir])
    }
    let(:new_config)              { environment.first }
    let(:aws_env)                 { environment[1] }
    let(:user_data)               { util.generate_user_data(config_dir:opts[:config_dir], **new_config) }
    let(:groups)                  { util.get_security_groups(opts[:config_dir], opts[:env], new_config[:group]) }
    # let(:elb_hash)                {{
    #   elb_name => new_config[:default_elb_parameters].merge!(elb_port: 80)
    # }}
    let(:zones)                    { new_config[:zones] }
    let(:security_groups)          { groups }

    before(:all) do
      @util = Tapjoy::AutoscalingBootstrap::Base.new
      @elb_name = 'test-elb'
      @cluster_filename = 'test_cluster.yaml'
      @opts = {
        env:        'qa',
        filename:   @cluster_filename,
        config_dir: 'spec/fixtures'
      }
      # # defaults_hash = util.load_yaml("#{opts[:config_dir]}/common/defaults.yaml")
      # config = util.load_yaml(cluster_filename, 'qa', opts[:config_dir])
      # # common_hash = util.load_yaml("#{opts[:config_dir]}/common/qa.yaml")
      @environment = @util.configure_environment(
        @opts[:filename],
        @opts[:env],
        @opts[:config_dir]
      )
      @elb_hash = {
        @elb_name => @environment.first[:default_elb_parameters].merge!(elb_port: 80)
      }
      @clobber_elb = true
      @zones = @environment.first[:zones]
      @security_groups = @util.get_security_groups(
        @opts[:config_dir], @opts[:env], @environment.first[:group])
    end

    before(:each) do
      Aws.config[:region] = new_config[:aws_region]
      Tapjoy::AutoscalingBootstrap.scaler_name = "#{cluster_name}-group"
      Tapjoy::AutoscalingBootstrap.config_name = "#{cluster_name}-config"
      Tapjoy::AutoscalingBootstrap.elb_name = @elb_name
    end
  end
end
