require 'aws-sdk-core'
require 'highline/import'
require 'base64'
require 'yaml'
require 'trollop'
require 'erb'

require_relative '../lib/tapjoy/autoscaling_bootstrap'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].to_a.each do |dir|
  require dir
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
    # This option will default to `true` in RSpec 4.
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # This option will default to `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  config.before(:each) do
    Aws.config[:stub_responses] = true
  end

  config.include BootstrapHelper
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = true
  c.default_cassette_options = { :record => :all }
end
