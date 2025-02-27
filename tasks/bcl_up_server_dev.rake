# frozen_string_literal: true
require 'bundler/gem_tasks'
require 'engine_cart/rake_task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc "Run continuous integration build"
task ci: ['engine_cart:generate'] do
  Rake::Task['spec'].invoke
end

desc 'Run continuous integration build'
task ci: [ 'spec']

task default: :ci
