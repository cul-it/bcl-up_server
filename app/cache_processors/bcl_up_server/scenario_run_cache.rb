# frozen_string_literal: true
# Maintain a cache controlling the execution of scenario tests.
module BCLUpServer
  class ScenarioRunCache
    class << self
      include BCLUpServer::CacheKeys

      # Run connection tests
      def run_tests(force: false)
        Rails.cache.fetch(cache_key, expires_in: next_expiry, race_condition_ttl: 30.seconds, force: force) do
          BCLUpServer.config.monitor_logger.debug("(BCLUpServer::ScenarioRunCache) - KICKING OFF TEST RUN (force: #{force})")
          BCLUpServer::MonitorTestsJob.perform_later
          "Test run initiated at #{BCLUpServer::TimeService.current_time}"
        end
      end

    private

      def cache_key
        "BCLUpServer::ScenarioRunCache.run_tests--latest_run_initiated"
      end

      def next_expiry
        BCLUpServer::CacheExpiryService.cache_expiry
      end
    end
  end
end
