# frozen_string_literal: true
# Provide access to the scenario_run_registry database table which registers each run of tests made over time.
module BclUpServer
  class ScenarioRunRegistry < ApplicationRecord
    self.table_name = 'scenario_run_registry'
    has_many :scenario_run_history, dependent: :destroy

    # @return [ScenarioRunRegistry] registry data for latest run (e.g. id, dt_stamp)
    def self.latest_run
      return nil unless BclUpServer::ScenarioRunRegistry.last
      BclUpServer::ScenarioRunRegistry.last # Can we count on last to always be the one with the latest dt_stamp?
      # latest_run = ScenarioRunRegistry.all.sort(:dt_stamp).last
      # return nil if latest_run.blank?
      # latest_run.id
    end

    # @return [Integer] id for latest test run
    # @deprecated Not used anywhere. Being removed.
    def self.latest_run_id
      latest = latest_run
      return nil unless latest
      lastest.id
    end
    deprecation_deprecate latest_run_id: "Not used anywhere. Being removed."

    # @return [ActiveSupport::TimeWithZone] datetime stamp of first registered run
    def self.first_run_dt
      Rails.cache.fetch("#{self.class}/#{__method__}", expires_in: BclUpServer::CacheExpiryService.cache_expiry, race_condition_ttl: 30.seconds) do
        BclUpServer::ScenarioRunRegistry.first.dt_stamp
      end
    end

    # Register and save latest test run results
    # @param scenarios_results [Array<Hash>] results of latest test run
    def self.save_run(scenarios_results:)
      run = BclUpServer::ScenarioRunRegistry.create(dt_stamp: BclUpServer::TimeService.current_time)
      scenarios_results.each { |result| BclUpServer::ScenarioRunHistory.save_result(run_id: run.id, scenario_result: result) }
    end
  end
end
