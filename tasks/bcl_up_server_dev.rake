# frozen_string_literal: true

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
task ci: ['engine_cart:generate', 'rubocop', 'spec']

desc 'Run continuous integration build without Rubocop'
task test_gem: ['engine_cart:generate', 'spec']

task default: :ci
