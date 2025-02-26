# frozen_string_literal: true
# Cache the datetime_stamp of the last time the performance day graph was generated.  Calls job to generate the graph if expired.
module BclUpServer
  class PerformanceDayGraphCache
    class << self
      # Generates graphs for the past 24 hours for :search, :fetch, and :all actions for each authority.
      # @param force [Boolean] if true, run the tests even if the cache hasn't expired; otherwise, use cache if not expired
      def generate_graphs(force: false)
        Rails.cache.fetch(cache_key, expires_in: next_expiry, race_condition_ttl: 30.seconds, force: force) do
          BclUpServer.config.monitor_logger.debug("(BclUpServer::PerformanceDayGraphCache) - KICKING OFF PERFORMANCE DAY GRAPH GENERATION (force: #{force})")
          BclUpServer::PerformanceDayGraphJob.perform_later
          "Graphs generation initiated at #{BclUpServer::TimeService.current_time}"
        end
      end

    private

      def cache_key
        "BclUpServer::PerformanceDayGraphCache.generate_graphs--latest_generation_initiated"
      end

      def next_expiry
        BclUpServer::CacheExpiryService.end_of_hour_expiry
      end
    end
  end
end
