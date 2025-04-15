# frozen_string_literal: true
require 'linkeddata'
require 'json'
require 'byebug'
require 'engine_cart'
require 'rails'

# ==============================================================================
# Set up test coverage reporting. Use Coveralls if COVERALLS_REPO_TOKEN is set.
# Only one coverage tool should initialize SimpleCov!
# ==============================================================================

if ENV['COVERALLS_REPO_TOKEN']
  require 'coveralls'
  Coveralls.wear!('rails') # this starts SimpleCov internally
else
  require 'simplecov'
  SimpleCov.start('rails') do
    add_filter '/.internal_test_app'
    add_filter '/lib/generators'
    add_filter '/spec'
    add_filter '/tasks'
    add_filter '/lib/qa/version.rb'
    add_filter '/lib/qa/engine.rb'

    at_exit do
      result = SimpleCov.result
      SimpleCov.formatter.new.format(result)

      # Skip coverage diff if last_run not available
      begin
        if File.exist?(SimpleCov::ResultMerger.resultset_path)
          SimpleCov::ResultMerger.merged_result
          SimpleCov.result_exit_status
        else
          warn "⚠️  Coverage diff skipped: no .last_run.json found"
        end
      rescue NoMethodError => e
        warn "⚠️  Coverage diff skipped due to error: #{e.message}"
      end
    end
  end

  SimpleCov.command_name 'spec'
end

# Load EngineCart
EngineCart.load_application!

require 'rspec/rails'
require 'webmock/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = File.expand_path("../fixtures", __FILE__)
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Disable Webmock if we choose so we can test against the authorities, instead of their mocks
  WebMock.disable! if ENV["WEBMOCK"] == "disabled"
end

# Helper methods
def webmock_fixture(fixture)
  File.new File.expand_path(File.join("../fixtures", fixture), __FILE__)
end

# returns the file contents
def load_fixture_file(fname)
  File.open(Rails.root.join('spec', 'fixtures', fname)) do |f|
    return f.read
  end
end

# Configuration for BclUpServer
BclUpServer.config.suppress_performance_gathering = true
BclUpServer.config.suppress_logging_performance_details = true
BclUpServer.config.preferred_time_zone_name = 'Eastern Time (US & Canada)'
