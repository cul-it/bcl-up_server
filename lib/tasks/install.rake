# frozen_string_literal: true
namespace :bcl_up_server do
  namespace :install do
    desc 'Copy migrations from BclUpServer to application'
    task migrations: :environment do
      BclUpServer::DatabaseMigrator.copy
    end
  end
end
