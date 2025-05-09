require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  # Generator is executed from /path/to/bcl_up_server/.internal_test_app/lib/generators/test_app_generator/
  # so the following path gets us to /path/to/bcl_up_server/spec/test_app_templates/
  source_root File.expand_path('../../../../spec/test_app_templates/', __FILE__)

  def install_engine
    generate 'bcl_up_server:install', '-f'
  end

  def banner
    say_status("info", "ADDING OVERRIDES FOR TEST ENVIRONMENT", :blue)
  end
end
