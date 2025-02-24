# frozen_string_literal: true
module BCLUpServer
  class Install < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc """
  This generator makes the following changes to your application:
  1. Runs bcl_up_server:models:install
  2. Injects BCLUpServer routes
  3. Installs bcl_up_server assets
         """

    def banner
      say_status('info', 'INSTALLING BCL_UP_SERVER', :blue)
    end

    def run_required_generators
      generate "bcl_up_server:assets"
      generate "bcl_up_server:config"
      generate "bcl_up_server:models#{options[:force] ? ' -f' : ''}"
    end

    # The engine routes have to come after the devise routes so that /users/sign_in will work
    def inject_routes
      say_status('info', '  -- adding bcl_up_server routes', :blue)

      # # Remove root route that was added by blacklight generator
      # gsub_file 'config/routes.rb', /root (:to =>|to:) "catalog#index"/, ''

      inject_into_file 'config/routes.rb', after: /Rails.application.routes.draw do\n/ do
        "  mount Qa::Engine => '/authorities'\n"\
        "  mount BCLUpServer::Engine, at: '/'\n"\
        "  resources :welcome, only: 'index'\n"\
        "  root 'bcl_up_server/homepage#index'\n"
      end
    end

    def inject_bootstrap
      say_status('info', '  -- adding bootstrap resources', :blue)

      inject_into_file 'app/views/layouts/application.html.erb', after: /<head>\n/ do
        "    <!-- Latest compiled and minified CSS -->\n"\
        "    <link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css'>\n"\
        "    <!-- jQuery library -->\n"\
        "    <script src='https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js'></script>\n"\
        "    <!-- Latest compiled JavaScript -->\n"\
        "    <script src='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js'></script>\n"
      end
    end

    def create_location_for_charts
      say_status('info', '  -- creating directory to hold dynamically generated charts', :blue)
      copy_file 'app/assets/images/bcl_up_server/charts/.keep'
    end
  end
end
