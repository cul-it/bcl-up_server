# frozen_string_literal: true
require 'linkeddata'
require 'json'
require 'engine_cart'
require 'simplecov'
require 'coveralls'
require 'byebug' unless ENV['TRAVIS']

ENV["RAILS_ENV"] ||= "test"

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start('rails') do
  add_filter '/.internal_test_app'
  add_filter '/lib/generators'
  add_filter '/spec'
  add_filter '/tasks'
  add_filter '/lib/qa/version.rb'
  add_filter '/lib/qa/engine.rb'
end
SimpleCov.command_name 'spec'

EngineCart.load_application!
Coveralls.wear!

require 'rspec/rails'
require 'webmock/rspec'

# 🔹 Manually load the Rails environment to ensure the engine is properly loaded
begin
  require File.expand_path('../../config/environment', __FILE__)
rescue LoadError => e
  puts "⚠️  Warning: Could not load Rails environment. Engine might not be fully loaded."
  puts e.message
end

# 🔹 Ensure all engine classes are loaded to prevent uninitialized constant errors
Rails.application.eager_load!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = File.expand_path("../fixtures", __FILE__)

  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Disable Webmock if we choose so we can test against the authorities, instead of their mocks
  WebMock.disable! if ENV["WEBMOCK"] == "disabled"

  config.infer_spec_type_from_file_location!
end

# 🔹 Check if `BclUpServer` is loaded, otherwise print a warning
unless defined?(BclUpServer)
  puts "⚠️  Warning: BclUpServer is not loaded! Tests might fail due to missing engine."
end

def webmock_fixture(fixture)
  File.new File.expand_path(File.join("../fixtures", fixture), __FILE__)
end

# returns the file contents
def load_fixture_file(fname)
  File.open(Rails.root.join('spec', 'fixtures', fname)) do |f|
    return f.read
  end
end

# 🔹 Ensure BclUpServer configuration is accessible
if defined?(BclUpServer)
  BclUpServer.config.suppress_performance_gathering = true
  BclUpServer.config.suppress_logging_performance_details = true
  BclUpServer.config.preferred_time_zone_name = 'Eastern Time (US & Canada)'
else
  puts "⚠️  Warning: BclUpServer config could not be set because the engine is not loaded."
end
