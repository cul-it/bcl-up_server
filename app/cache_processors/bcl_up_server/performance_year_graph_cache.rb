# frozen_string_literal: true
# Cache the datetime_stamp of the last time the performance year graph was generated.  Calls job to generate the graph if expired.
module BclUpServer
  class PerformanceYearGraphCache
    class << self
      # Generates graphs for the 12 months for :search, :fetch, and :all actions for each authority.
      # @param force [Boolean] if true, run the tests even if the cache hasn't expired; otherwise, use cache if not expired
      def generate_graphs(force: false)
        Rails.cache.fetch(cache_key, expires_in: next_expiry, race_condition_ttl: 30.seconds, force:) do
          BclUpServer.config.monitor_logger.debug("(BclUpServer::PerformanceYearGraphCache) - KICKING OFF PERFORMANCE YEAR GRAPH GENERATION (force: #{force})")
          BclUpServer::PerformanceYearGraphJob.perform_later
          "Graphs generation initiated at #{BclUpServer::TimeService.current_time}"
        end
      end

    private

      def cache_key
        "BclUpServer::PerformanceYearGraphCache.generate_graphs--latest_generation_initiated"
      end

      def next_expiry
        BclUpServer::CacheExpiryService.cache_expiry
      end
    end
  end
end
