# frozen_string_literal: true
# Load system override BEFORE anything else (esp. engine_cart)
require_relative '../lib/overrides/kernel_patch'

require 'bundler/gem_tasks'
require 'engine_cart/rake_task'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc 'Run style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rspec'
  task.fail_on_error = true
end

desc 'Run continuous integration build with Rubocop'
task test_all: ['engine_cart:generate', 'rubocop', 'spec']

desc 'Run continuous integration build without Rspec'
task test_gem: ['engine_cart:generate', 'spec']

desc 'Run continuous integration build without Rubocop'
task test_rubocop: ['engine_cart:generate', 'rubocop']

task default: :test_all
