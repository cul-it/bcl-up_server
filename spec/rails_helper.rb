# frozen_string_literal: true

require 'spec_helper'
ENV["RAILS_ENV"] ||= "test"

# Load the Rails application (from EngineCart)
engine_cart_environment = File.expand_path("../.internal_test_app/config/environment.rb", __dir__)
unless File.exist?(engine_cart_environment)
  raise "EngineCart test app environment not found at #{engine_cart_environment}"
end
require engine_cart_environment

require "rspec/rails"
require "webmock/rspec"

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.order = "random"

  WebMock.disable! if ENV["WEBMOCK"] == "disabled"
end
