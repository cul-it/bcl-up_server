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
bundle config build.sqlite3 \
  --with-sqlite3-include=/usr/include \
  --with-sqlite3-lib=/usr/lib64

# Verify Bundler installation
print_msg "💠 which bundle: $(which bundle)"
print_msg "💠 bundle --version: $(bundle --version)"

# Avoid native extension issues like with Nokogiri + GLIBC mismatch
rm -f Gemfile.
bundle lock --add-platform ruby
export BUNDLE_FORCE_RUBY_PLATFORM=true
bundle config set --local force_ruby_platform true
#bundle config set --global force_ruby_platform true

print_msg "💠 global bundle config: $(bundle config --global)"
print_msg "💠 local bundle config: $(bundle config --local)"

# Install dependencies
bundle install

print_msg "💠 ENGINE_CART_DESTINATION: $ENGINE_CART_DESTINATION"
print_msg "💠 RAILS_ROOT: $RAILS_ROOT"
print_msg "💠 Checking for engine_cart rake task"
bundle exec rake -T | grep engine_cart || echo "⚠️ engine_cart rake task not found"


# Generate the internal test Rails app
print_msg "💠 Generating internal test app"
bundle exec rake engine_cart:generate

# Move into the generated test app
cd .internal_test_app

# Run your gem’s installer generator
print_msg "💠 Running bcl_up_server:install generator"
bundle exec rails generate bcl_up_server:install

# Copy any migrations your gem provides
print_msg "💠 Copying migrations"
bundle exec rake bcl_up_server:install:migrations

## run database migrations
#rake db:migrate

# Conditionally delete and recreate the database
if [ "${DELETE_DATABASE}" = "true" ]; then
  print_msg "💠 Deleting and recreating the database"
  bundle exec rake db:drop db:create
fi

# Run database migrations
print_msg "💠 Running database migrations"
bundle exec rake db:migrate
