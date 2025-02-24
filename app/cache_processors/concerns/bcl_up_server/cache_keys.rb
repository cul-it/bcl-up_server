# frozen_string_literal: true
# This module sets up the keys used to identify data in Rails.cache
module BCLUpServer
  module CacheKeys
    SCENARIO_RUN_SUMMARY_DATA_CACHE_KEY = "BCLUpServer--CacheKeys--scenario_run_summary_data"
    SCENARIO_RUN_FAILURE_DATA_CACHE_KEY = "BCLUpServer--CacheKeys--scenario_run_failure_data"
    SCENARIO_RUN_HISTORY_DATA_CACHE_KEY = "BCLUpServer--CacheKeys--scenario_run_history_data"
    SCENARIO_RUN_HISTORY_UP_DOWN_DATA_CACHE_KEY = "BCLUpServer--CacheKeys--history_up_down_data"

    PERFORMANCE_DATATABLE_DATA_CACHE_KEY = "BCLUpServer--Cache--performance_datatable_data"
  end
end
