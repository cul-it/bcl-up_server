# frozen_string_literal: true
require 'rails/generators'
require 'rails/generators/active_record'

module BclUpServer
  # BclUpServer::DatabaseMigrator is responsible for copying BclUpServer's required database
  # migrations into applications. Rails engines typically use the built-in
  # `{ENGINE_NAME}:install:migrations` task to handle this; instead BclUpServer
  # follows the practice used by Devise to dynamically subclass migrations with
  # the version of `ActiveRecord::Migration` corresponding to the version of
  # Rails used by the application.
  #
  # @note BclUpServer::DatabaseMigrator uses Rails' generator internals to avoid
  #       having to re-implement code that knows how to copy migrations only if
  #       needed
  class DatabaseMigrator < Rails::Generators::Base
    # @note included to pick up AR's migration numbering algorithm
    include ActiveRecord::Generators::Migration

    # @note This method is required by Rails::Generators::Base
    def self.source_root
      migrations_dir
    end

    def self.migrations_dir
      BclUpServer::Engine.root.join('lib', 'generators', 'bcl_up_server', 'templates')
    end

    def self.copy
      new.copy
    end

    # def copy
    #   # QA Server's migrations changed between 2.0.0 and subsequent versions, so the
    #   # migration comparison algorithm decides that those older migrations are a
    #   # source of conflict. Default Rails behavior here is to abort and
    #   # explicitly instruct the user to try again with either the `--skip` or
    #   # `--force` option. QA Server skips these conflicts.
    #   migrations.each do |filename|
    #     migration_template filename,
    #                        "db/migrate/#{parse_basename_from(filename)}",
    #                        migration_version: migration_version,
    #                        skip: true
    #   end
    # end
    def copy
      migrations.each do |filename|
        migration_template filename,
                           "db/migrate/#{parse_basename_from(filename)}",
                           migration_version:
      end
    end

  private

    def migrations
      Dir.chdir(self.class.migrations_dir) { Dir.glob('db/migrate/[0-9]*_*.rb.erb') }.sort
    end

    def parse_basename_from(filename)
      # Add engine name to filename to mimic ``ActiveRecord::Migration.copy` behavior
      filename.slice(/(?<dateprefix>\d)+_(?<basename>.+)\.erb/, 'basename').sub('.', '.bcl_up_server.')
    end

    def migration_version
      # Don't use AR migration versioning in Rails 4
      return if Rails.version < '5.0.0'
      # Specify the current major.minor version of Rails for AR migrations
      "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
    end
  end
end
