# frozen_string_literal: true
# Maintain a cache of data for Authority Connection History table displayed on Monitor Status page
module BclUpServer
  class ScenarioHistoryCache
    class_attribute :scenario_history_class, :scenario_up_down_class
    self.scenario_history_class = BclUpServer::ScenarioRunHistory
    self.scenario_up_down_class = BclUpServer::HistoryUpDownService

    class << self
      include BclUpServer::CacheKeys

      # Get a summary of the number of days passing/failing for scenario runs during configured time period
      # @param force [Boolean] if true, run the tests even if the cache hasn't expired; otherwise, use cache if not expired
      # @returns [Array<Hash>] count of days with passing/failing tests for each authority
      # @example [auth_name, failing, passing]
      #   { 'agrovoc' => { good: 31, bad: 2 },
      #     'geonames_ld4l_cache' => { good: 32, bad: 1 } }
      def historical_summary(force: false)
        Rails.cache.fetch(cache_key_for_historical_data, expires_in: next_expiry, race_condition_ttl: 30.seconds, force:) do
          BclUpServer.config.monitor_logger.debug("(BclUpServer::ScenarioHistoryCache) - CALCULATING HISTORY of scenario runs (force: #{force})")
          scenario_history_class.historical_summary
        end
      end

      # Get a status for each of the last 30 days for queries that succeeded or failed.
      # @param force [Boolean] if true, run the tests even if the cache hasn't expired; otherwise, use cache if not expired
      # @returns [Hash<Array>] status for the last 30 days for each authority
      # @example { auth_name => [:fully_up, :fully_up, :down, :mostly_up, ... ], ... }
      #   { 'agrovoc' => [ :fully_up, :fully_up, :down, :mostly_up, ...],
      #     'geonames_ld4l_cache' => [ :fully_up, :mostly_up, :down, :fully_up, :timeouts, ...] }
      def historical_up_down_data(force: false)
        Rails.cache.fetch(cache_key_for_historical_up_down_data, expires_in: next_expiry, race_condition_ttl: 30.seconds, force:) do
          BclUpServer.config.monitor_logger.debug("(BclUpServer::ScenarioHistoryCache) - CALCULATING UP-DOWN STATUS HISTORY of scenario runs (force: #{force})")
          scenario_up_down_class.new.last_30_days
        end
      end

    private

      def cache_key_for_historical_data
        SCENARIO_RUN_HISTORY_DATA_CACHE_KEY
      end

      def cache_key_for_historical_up_down_data
        SCENARIO_RUN_HISTORY_UP_DOWN_DATA_CACHE_KEY
      end

      def next_expiry
        BclUpServer::CacheExpiryService.cache_expiry
      end
    end
  end
end
