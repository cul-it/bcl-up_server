# Force local platform gem installation for Nokogiri
say_status :info, "##################################################", :blue
say_status :info, "rails template executed", :green
say_status :info, "##################################################", :blue

say_status :info, "Uninstalling older nokogiri...", :blue
run "gem uninstall nokogiri -aIx || true"

say_status :info, "force_ruby_platform true...", :blue
run "bundle config set force_ruby_platform true"
say_status :info, "Install correct nokogiri...", :blue
say_status :info, "##################################################", :blue
run "gem install nokogiri --platform=ruby"
say_status :info, "##################################################", :blue
say_status :info, "bundle install...", :blue
run "bundle _2.4.19_ install"