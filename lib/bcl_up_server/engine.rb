# frozen_string_literal: true
module BclUpServer
  class Engine < ::Rails::Engine
    isolate_namespace BclUpServer

    require 'qa'

    def self.engine_mount
      BclUpServer::Engine.routes.find_script_name({})
    end

    def self.qa_engine_mount
      Qa::Engine.routes.find_script_name({})
    end

    # Force these models to be added to Legato's registry in development mode
    config.eager_load_paths += %W[
      #{config.root}/app/models/bcl_up_server/download.rb
      #{config.root}/app/models/bcl_up_server/pageview.rb
    ]

    initializer 'bcl_up_server.assets.precompile' do |app|
      app.config.assets.paths << config.root.join('vendor', 'assets', 'fonts')
      app.config.assets.paths << config.root.join('app', 'assets', 'images')
      app.config.assets.paths << config.root.join('app', 'assets', 'stylesheets')
      app.config.assets.precompile += %w[*.png *.jpg *.ico *.gif *.svg]

      if Rails.env.production?
        app.config.assets.precompile += %w[ bcl_up_server/bcl_up_server.scss ]
        app.config.assets.precompile += %w[*.png *.jpg *.ico *.gif *.svg]
      end
    end
  end
end
