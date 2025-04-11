# frozen_string_literal: true
require 'rails/generators'

class BclUpServer::AssetsGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc """
    This generator installs the bcl_up_server CSS and JavaScript assets into your application.
  """

  def banner
    say_status('info', 'GENERATING BCL_UP_SERVER ASSETS', :blue)
  end

  def inject_css
    say_status('info', '  -- adding bcl_up_server css', :blue)
    copy_file "bcl_up_server.scss", "app/assets/stylesheets/bcl_up_server.scss"
  end

  def inject_js
    js_file_path = 'app/assets/javascripts/application.js'

    say_status('info', "Checking if #{js_file_path} exists...", :yellow)

    unless File.exist?(js_file_path)
      say_status('warning', "  -- #{js_file_path} not found! Creating it now...", :red)
      create_file js_file_path, "//= require_tree .\n//= require_self\n"
    end

    if bcl_up_server_javascript_installed?(js_file_path)
      say_status('info', "  -- bcl_up_server already included in #{js_file_path}, skipping.", :blue)
      return
    end

    say_status('info', "  -- adding bcl_up_server javascript to #{js_file_path}", :blue)
    insert_into_file js_file_path, after: '//= require_tree .' do
      <<-JS.strip_heredoc

        //= require bcl_up_server
      JS
    end
  end

  private

  def bcl_up_server_javascript_installed?(file_path)
    say_status('info', "Checking if #{file_path} contains 'bcl_up_server'...", :yellow)
    return false unless File.exist?(file_path)

    content = IO.read(file_path)
    content.include?('bcl_up_server')
  rescue Errno::ENOENT
    say_status('error', "  -- ERROR: Could not read #{file_path}!", :red)
    false
  end
end
