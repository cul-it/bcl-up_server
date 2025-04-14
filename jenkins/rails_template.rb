# Force local platform gem installation for Nokogiri
run "bundle config set force_ruby_platform true"
run "gem uninstall nokogiri -aIx || true"
run "gem install nokogiri --platform=ruby"
run "bundle install"