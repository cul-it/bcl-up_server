#!/bin/bash
set -e
set +x

source scripts/log_utils.sh
source jenkins/environment.sh

print_header "💻 Executing rspec-tests.sh"
print_msg "💠 PATH: $PATH"

print_list "$(
  echo "pwd: $(pwd)"
  ls -l
)"

# Use env files in Gemfile.extra
export JENKINS=true

print_msg "💠 Running all rspec tests..."
# Generate the internal test Rails app
print_msg "💠 Generating internal test app"
if [ -d ".internal_test_app" ]; then
  print_msg "⚠️  .internal_test_app already exists before generation!"
  print_msg "💠 Cleaning previous test app"
  bundle exec rake engine_cart:clean
else
  print_msg "✅ No .internal_test_app found before generation"
fi

print_msg "💠 bundle exec rake test_gem..."

COVERAGE=true bundle exec rake test_gem
