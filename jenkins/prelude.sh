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

# Install base dependencies
bundle install
