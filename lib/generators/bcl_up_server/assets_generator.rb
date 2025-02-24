# frozen_string_literal: true
require 'rails/generators'

class BCLUpServer::AssetsGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc """
    This generator installs the bcl_up_server CSS assets into your application
       """

  def banner
    say_status('info', 'GENERATING BCL_UP_SERVER ASSETS', :blue)
  end

  def inject_css
    say_status('info', '  -- adding bcl_up_server css', :blue)
    copy_file "bcl_up_server.scss", "app/assets/stylesheets/bcl_up_server.scss"
  end

  def inject_js
    return if bcl_up_server_javascript_installed?
    say_status('info', '  -- adding bcl_up_server javascript', :blue)
    insert_into_file 'app/assets/javascripts/application.js', after: '//= require_tree .' do
      <<-JS.strip_heredoc

        //= require bcl_up_server
      JS
    end
  end

private

  def bcl_up_server_javascript_installed?
    IO.read("app/assets/javascripts/application.js").include?('bcl_up_server')
  end
end
