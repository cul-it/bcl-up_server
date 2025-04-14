#!/bin/bash
# bundler for automated tests
source "scripts/log_utils.sh"
set -e
#cd bcl-up_server_container
source jenkins/environment.sh

print_header "💻 Executing prelude.sh"

# Ensure the PATH includes the directory where Bundler is installed
export PATH=$GEM_HOME/bin:$PATH

# Force native gem compilation (avoid incompatible precompiled binaries with GLIBC)
bundle config set force_ruby_platform true
# Force use sqlite version in jenkins
bundle config build.sqlite3 \
  --with-sqlite3-include=/usr/include \
  --with-sqlite3-lib=/usr/lib64

# Verify Bundler installation
print_msg "💠 which bundle: $(which bundle)"
print_msg "💠 bundle --version: $(bundle --version)"

# Install dependencies
bundle install

# Generate the internal test Rails app
print_msg "💠 Generating internal test app"
bundle exec engine_cart generate

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
