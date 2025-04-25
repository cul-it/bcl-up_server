#!/bin/bash
set +x
source "scripts/log_utils.sh"
source jenkins/chromedriver-verifier.sh

print_header "💻 Executing environment.sh"
print_msg "🪾 Branch: $(git rev-parse --abbrev-ref HEAD)"
print_msg "🏠 JENKINS_HOME: $JENKINS_HOME"

# Add project bin directory to PATH
PATH=$PWD/bin:$PATH
print_msg "💠 PATH: $PATH"

# Load RVM and use correct Ruby version
source /etc/profile.d/rvm.sh
RUBYVERSION=ruby-3.4.2
print_msg "💠 Ruby: $RUBYVERSION"
GEM_HOME="/usr/local/rvm/gems/$RUBYVERSION"
rvm use "$RUBYVERSION"

# Check if nokogiri 1.18.7 is installed; if not, install it
if ! gem list nokogiri -v 1.18.7 --installed > /dev/null 2>&1; then
  print_msg "🔧 Installing nokogiri 1.18.7 for Ruby $RUBYVERSION..."
  gem install nokogiri -v 1.18.7 --platform ruby
else
  print_msg "✅ nokogiri 1.18.7 already installed"
fi


# Copy environment file, or create one if it doesn't exist
ENV_PATH="/cul/data/jenkins/environments/bcl-up_server.env"

if [ -f "$ENV_PATH" ]; then
  print_msg "✅ Found env file at $ENV_PATH"
  cp "$ENV_PATH" .env
else
  print_msg "⚠️  Missing $ENV_PATH, creating fallback $ENV_PATH and local .env"
  cat <<EOF | tee "$ENV_PATH" .env > /dev/null
MYSQL_ROOT_PASSWORD=jenkins_secret
MYSQL_DATABASE_NAME_PREFIX=jenkins_bclup
MYSQL_USER=jenkins_bclup_test
MYSQL_PASSWORD=jenkins_secret
RAILS_ENV=test
EOF
fi
