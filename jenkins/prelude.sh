#!/bin/bash
# bundler for automated tests
source "scripts/log_utils.sh"
set -e
#cd bcl-up_server_container
source jenkins/environment.sh

print_header "💻 Executing prelude.sh"

# Ensure the PATH includes the directory where Bundler is installed
export PATH=$GEM_HOME/bin:$PATH

# Force use sqlite version in jenkins
#bundle config build.sqlite3 \
#  --with-sqlite3-include=/usr/include \
#  --with-sqlite3-lib=/usr/lib64

# Verify Bundler installation
print_msg "💠 which bundle: $(which bundle)"
print_msg "💠 bundle --version: $(bundle --version)"

# Avoid native extension issues like with Nokogiri + GLIBC mismatch
#gem uninstall bundler
#gem install bundler -v 2.4.19

rm -f Gemfile.
export NOKOGIRI_USE_SYSTEM_LIBRARIES=true
#export BUNDLE_FORCE_RUBY_PLATFORM=true
#bundle config set --local force_ruby_platform true


# Ensure Nokogiri gets compiled locally (not precompiled)
print_msg "💠 nokogiri info (before): $(gem list | grep nokogiri)"
gem uninstall nokogiri -aIx || true
gem install nokogiri --platform=ruby
print_msg "💠 nokogiri info (after): $(bundle info nokogiri || echo 'nokogiri not found')"

# Install dependencies
#bundle install
bundle install
print_msg "💠 nokogiri info: $(bundle info nokogiri)"
print_msg "💠 Checking for engine_cart rake task"
echo "✅ Using Jenkins template with ENGINE_CART_RAILS_OPTIONS"

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
bundle exec rake test_gem


# Move into the generated test app
#print_line
#print_line
#print_msg "📂 moving to .internal_test_app"
#cd .internal_test_app
#
#export NOKOGIRI_USE_SYSTEM_LIBRARIES=true
#export BUNDLE_FORCE_RUBY_PLATFORM=true
#bundle _2.4.19_ config set --local force_ruby_platform true
## Ensure Nokogiri gets compiled locally (not precompiled)
#print_msg "💠 nokogiri info (before): $(gem list | grep nokogiri)"
#gem uninstall nokogiri -aIx || true
#gem install nokogiri --platform=ruby
#print_msg "💠 nokogiri info (after): $(bundle info nokogiri || echo 'nokogiri not found')"
#
#print_msg "💠 global bundle config: $(bundle config --global)"
#print_msg "💠 local bundle config: $(bundle config --local)"
#bundle _2.4.19_ install
#print_line
#print_line

# Run your gem’s installer generator
#print_msg "💠 Running bcl_up_server:install generator"
#bundle _2.4.19_ exec rails generate bcl_up_server:install

# Copy any migrations your gem provides
#print_msg "💠 Copying migrations"
#bundle _2.4.19_ exec rake bcl_up_server:install:migrations

## run database migrations
#rake db:migrate

# Conditionally delete and recreate the database
#if [ "${DELETE_DATABASE}" = "true" ]; then
#  print_msg "💠 Deleting and recreating the database"
#  bundle exec rake db:drop db:create
#fi

# Run database migrations
#print_msg "💠 Running database migrations"
#bundle _2.4.19_ exec rake db:migrate
