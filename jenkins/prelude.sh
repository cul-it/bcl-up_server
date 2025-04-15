#!/bin/bash
source "scripts/log_utils.sh"
set -e
source jenkins/environment.sh

print_header "💻 Executing prelude.sh"

# Ensure the PATH includes the directory where Bundler is installed
export PATH=$GEM_HOME/bin:$PATH

# Verify Bundler installation
print_msg "💠 which bundle: $(which bundle)"
print_msg "💠 bundle --version: $(bundle --version)"

# Avoid native extension issues like with Nokogiri + GLIBC mismatch
#rm -f Gemfile.
#export NOKOGIRI_USE_SYSTEM_LIBRARIES=true
#
## Ensure Nokogiri gets compiled locally (not precompiled)
#print_msg "💠 nokogiri info (before): $(gem list | grep nokogiri)"
#gem uninstall nokogiri -aIx || true
#gem install nokogiri --platform=ruby
#print_msg "💠 nokogiri info (after): $(bundle info nokogiri || echo 'nokogiri not found')"

# Install base dependencies
bundle install
