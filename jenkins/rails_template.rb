# Force local platform gem installation for Nokogiri
say_status :info, "##################################################", :blue
say_status :info, "rails template executed", :green
say_status :info, "##################################################", :blue

run "gem uninstall nokogiri -aIx || true"
run "bundle config set force_ruby_platform true"
run "gem install nokogiri --platform=ruby"
run "bundle _2.4.19_ install"