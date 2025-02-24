# frozen_string_literal: true
namespace :bcl_up_server do
  namespace :install do
    desc 'Copy migrations from BCLUpServer to application'
    task migrations: :environment do
      BCLUpServer::DatabaseMigrator.copy
    end
  end
end
