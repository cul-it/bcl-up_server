# frozen_string_literal: true
# Maintain a cache controlling the execution of scenario tests.
module BclUpServer
  class ScenarioRunCache
    class << self
      include BclUpServer::CacheKeys

      # Run connection tests
      def run_tests(force: false)
        Rails.cache.fetch(cache_key, expires_in: next_expiry, race_condition_ttl: 30.seconds, force: force) do
          BclUpServer.config.monitor_logger.debug("(BclUpServer::ScenarioRunCache) - KICKING OFF TEST RUN (force: #{force})")
          BclUpServer::MonitorTestsJob.perform_later
          "Test run initiated at #{BclUpServer::TimeService.current_time}"
        end
      end

    private

      def cache_key
        "BclUpServer::ScenarioRunCache.run_tests--latest_run_initiated"
      end

      def next_expiry
        BclUpServer::CacheExpiryService.cache_expiry
      end
    end
  end
end
