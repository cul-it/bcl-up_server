# frozen_string_literal: true
# Provide access to the scenario_run_history database table which tracks scenario runs over time.
module BclUpServer
  class ScenarioRunHistory < ApplicationRecord # rubocop:disable Metrics/ClassLength
    self.table_name = 'scenario_run_history'
    belongs_to :scenario_run_registry
    enum scenario_type: { connection: 0, accuracy: 1, performance: 2 }, _suffix: :type
    enum status: { good: 0, bad: 1, unknown: 2 }, _suffix: true

    GOOD_MARKER = '√'
    BAD_MARKER = 'X'
    UNKNOWN_MARKER = '?'

    class_attribute :summary_class, :authority_lister_class
    self.summary_class = BclUpServer::ScenarioRunSummary
    self.authority_lister_class = BclUpServer::AuthorityListerService

    class << self
      # Save a scenario result
      # @param run_id [Integer] the run on which to gather statistics
      # @param result [Hash] the scenario result to be saved
      def save_result(run_id:, scenario_result:)
        registry = BclUpServer::ScenarioRunRegistry.find(run_id)
        BclUpServer::ScenarioRunHistory.create(scenario_run_registry_id: run_id,
                                               status: scenario_result[:status],
                                               authority_name: scenario_result[:authority_name],
                                               subauthority_name: scenario_result[:subauthority_name],
                                               service: scenario_result[:service],
                                               action: scenario_result[:action],
                                               url: scenario_result[:url],
                                               err_message: scenario_result[:err_message],
                                               run_time: scenario_result[:run_time],
                                               date: registry.dt_stamp.to_date)
      end

      # Get a summary of passing/failing tests for a run.
      # @param scenario_run [BclUpServer::ScenarioRunRegistry] the run on which to gather statistics
      # @returns [BclUpServer::ScenarioRunSummary] statistics on the requested run
      # @example ScenarioRunSummary includes methods for accessing
      #   * run_id           [Integer] e.g. 14
      #   * run_dt_stamp     [ActiveSupport::TimeWithZone] e.g. Wed, 19 Feb 2020 16:01:07 UTC +00:00
      #   * authority_count  [Integer] e.g. 22
      #   * failing_authority_count [Integer] e.g. 1
      #   * passing_scenario_count  [Integer] e.g. 156
      #   * failing_scenario_count  [Integer] e.g. 3
      #   * total_scenario_count    [Integer] e.g. 159
      def run_summary(scenario_run:)
        status = status_counts_in_run(run_id: scenario_run.id)
        summary_class.new(run_id: scenario_run.id,
                          run_dt_stamp: scenario_run.dt_stamp,
                          authority_count: authorities_in_run(run_id: scenario_run.id).count,
                          failing_authority_count: authorities_with_failures_in_run(run_id: scenario_run.id).count,
                          passing_scenario_count: status['good'],
                          failing_scenario_count: status['bad'] + status['unknown'])
      end

      # Get set of failures for a run, if any.
      # @param run_id [Integer] the run on which to gather statistics
      # @returns [Array<Hash>] scenario details for any failing scenarios in the run
      # @example
      #   [ { status: :bad,
      #       authority_name: "geonames_ld4l_cache",
      #       subauthority_name: "area",
      #       service: "ld4l_cache",
      #       action: "search",
      #       url: "/qa/search/linked_data/geonames_ld4l_cache/area?q=France&maxRecords=4",
      #       err_message: "Unable to connect to authority",
      #       scenario_type: :connection
      #       run_time: 11.2 },
      #     { status: :unknown,
      #       authority_name: "oclcfast_ld4l_cache",
      #       subauthority_name: "Person",
      #       service: "ld4l_cache",
      #       action: "search",
      #       url: "/qa/search/linked_data/oclcfast_ld4l_cache/person?q=mark twain&maxRecords=4",
      #       err_message: "Not enough search results returned",
      #       scenario_type: :connection
      #       run_time: 0.123 } ]
      def run_failures(run_id:)
        return [] unless run_id
        BclUpServer::ScenarioRunHistory.where(scenario_run_registry_id: run_id).where.not(status: :good).to_a
      end

      # Get a summary of the number of days passing/failing for scenario runs during configured time period
      # @returns [Array<Hash>] count of days with passing/failing tests for each authority
      # @example [auth_name, failing, passing]
      #   { 'agrovoc' => { good: 31, bad: 2 },
      #     'geonames_ld4l_cache' => { good: 32, bad: 1 } }
      def historical_summary
        days_good = count_days(:good)
        days_bad = count_days(:bad)
        days_unknown = count_days(:unknown)
        keys = (days_good.keys + days_bad.keys + days_unknown.keys).uniq.sort
        keys.each_with_object({}) do |auth, hash|
          next unless active_authority? auth
          hash[auth] = { good: day_count(auth, days_good), bad: day_count(auth, days_bad) + day_count(auth, days_unknown) }
        end
      end

    private

      def active_authority?(auth)
        active_authorities.include? auth.to_sym
      end

      def active_authorities
        @active_authorities = authority_lister_class.authorities_list
      end

      def day_count(auth, days)
        days&.key?(auth) ? days[auth] : 0
      end

      def count_days(status)
        where = time_period_where
        where[:status] = status
        auths = BclUpServer::ScenarioRunHistory.where(where).select("authority_name").group("date, authority_name")
                                            .order("authority_name").pluck(:authority_name)
        auths.each_with_object({}) do |auth, hash|
          hash[auth] = 0 unless hash.key? auth
          hash[auth] += 1
        end
      end

      def authorities_in_run(run_id:)
        BclUpServer::ScenarioRunHistory.where(scenario_run_registry_id: run_id).pluck(:authority_name).uniq
      end

      def authorities_with_failures_in_run(run_id:)
        BclUpServer::ScenarioRunHistory.where(scenario_run_registry_id: run_id).where.not(status: 'good').pluck('authority_name').uniq
      end

      # @return [Hash] status counts across all authorities (used for current test summary)
      # @example { "good" => 23, "bad" => 3, "unknown" => 0 }
      def status_counts_in_run(run_id:)
        status = BclUpServer::ScenarioRunHistory.group('status').where(scenario_run_registry_id: run_id).count
        status["good"] = 0 unless status.key? "good"
        status["bad"] = 0 unless status.key? "bad"
        status["unknown"] = 0 unless status.key? "unknown"
        status
      end

      def runs_per_authority_for_time_period
        status = BclUpServer::ScenarioRunHistory.joins(:scenario_run_registry).where(time_period_where).group('authority_name', 'status').count
        status.each_with_object({}) do |(k, v), hash|
          h = hash[k[0]] || { "good" => 0, "bad" => 0 } # initialize for an authority if it doesn't already exist
          h[k[1]] = v
          hash[k[0]] = h
        end
      end

      def expected_time_period
        BclUpServer.config.historical_datatable_default_time_period
      end

      def time_period_where
        case expected_time_period
        when :day
          BclUpServer::TimePeriodService.where_clause_for_last_24_hours(dt_table: :scenario_run_history, dt_column: :date)
        when :month
          BclUpServer::TimePeriodService.where_clause_for_last_30_days(dt_table: :scenario_run_history, dt_column: :date)
        when :year
          BclUpServer::TimePeriodService.where_clause_for_last_12_months(dt_table: :scenario_run_history, dt_column: :date)
        else
          all_records
        end
      end
    end
  end
end
