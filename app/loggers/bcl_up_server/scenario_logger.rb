# frozen_string_literal: true
# Provide a log of scenario data and test results
module BclUpServer
  class ScenarioLogger
    include Enumerable

    # @return the number of scenarios recorded in the log
    delegate :size, :each, to: :@log

    attr_reader :test_count, :failure_count

    PASS = BclUpServer::ScenarioValidator::PASS
    FAIL = BclUpServer::ScenarioValidator::FAIL
    UNKNOWN = BclUpServer::ScenarioValidator::UNKNOWN

    def initialize(test_count = 0, failure_count = 0)
      @log = []
      @test_count = test_count
      @failure_count = failure_count
    end

    # Add a scenario to the log
    # @param [Hash] status_info holding information to be logged
    # @option authority_name [String] name of the authority the scenario was run against
    # @option status [Symbol] indicating whether the scenario passed, failed, or has unknown status (see PASS, FAIL, UNKNOWN constants)
    # @option validation_type [Symbol] the type of validation this status data describes (e.g. :connection, :accuracy)
    # @option subauth [String] name of the subauthority the scenario was run against
    # @option service [String] identifies the primary service provider (e.g. 'ld4l_cache', 'direct', etc.)
    # @option action [String] type of scenario (i.e. 'term', 'search')
    # @option url [String] example url that was used to test a specific term fetch or search query
    # @option request_data [String] either the query for searches or the requested id/uri for fetch
    # @option error_message [String] error message if scenario failed
    # @option expected [Integer] the expected result (e.g. min size of result OR max position of subject within results)
    # @option actual [Integer] the actual result (e.g. actual size of results OR actual position of subject within results)
    # @option target [String] the expected target that was validated (e.g. subject_uri for query, pref label for term fetch)
    # @option request_run_time [BigDecimal] the amount of time to retrieve data from the authority
    # @option normalization_run_time [BigDecimal] the amount of time to normalize the retrieved data into json
    def add(status_info) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
      @test_count += 1
      @failure_count += 1 unless status_info[:status] == PASS
      @log << { type: status_info[:validation_type] || '',
                status: status_info[:status] || '',
                authority_name: status_info[:authority_name] || '',
                subauthority_name: status_info[:subauth] || '',
                service: status_info[:service] || '',
                action: status_info[:action] || '',
                url: status_info[:url] || '',
                request_data: status_info[:request_data] || '',
                expected: status_info[:expected] || nil,
                actual: status_info[:actual] || nil,
                target: status_info[:target] || nil,
                err_message: status_info[:error_message] || '',
                request_run_time: status_info[:request_run_time] || nil,
                normalization_run_time: status_info[:normalization_run_time] || nil,
                pending: status_info[:pending] || false }
    end

    # Delete from the log any tests that passed.
    def delete_passing
      @log.delete_if { |entry| entry[:status] == PASS }
    end

    # Append a log to this log.
    # @param [ScenarioLog] the log to append to this log
    def append(other)
      return if other.blank?
      @log += other.to_a
      @test_count += other.test_count
      @failure_count += other.failure_count
    end

    # @return selected scenario test results data as an array limited to the specified type or all scenarios if type is nil
    # @example ungrouped
    #   [ { type: :accuracy_test,
    #       status: :PASS,
    #       authority_name: 'CERL_LD4L_CACHE',
    #       subauthority_name: 'imprint',
    #       service: 'ld4l_cache',
    #       action: 'search',
    #       url: '/qa/search/linked_data/cerl_ld4l_cache/imprint?q=Plantin&maxRecords=8',
    #       request_data: 'Plantin',
    #       expected: 1,
    #       actual: 1,
    #       target: 'http://thesaurus.cerl.org/record/cni00007649',
    #       err_message: '',
    #       request_run_time: 0.032,
    #       normalization_run_time: 0.011,
    #       pending: false },
    #       ... ]
    # @example grouped
    #   { CERL_LD4L_CACHE =
    #       [ { type: :accuracy_test,
    #           status: :PASS,
    #           authority_name: 'CERL_LD4L_CACHE',
    #           subauthority_name: 'imprint',
    #           service: 'ld4l_cache',
    #           action: 'search',
    #           url: '/qa/search/linked_data/cerl_ld4l_cache/imprint?q=Plantin&maxRecords=8',
    #           request_data: 'Plantin',
    #           expected: 1,
    #           actual: 1,
    #           target: 'http://thesaurus.cerl.org/record/cni00007649',
    #           err_message: '',
    #           request_run_time: 0.032,
    #           normalization_run_time: 0.011,
    #           pending: false },
    #           ... # all others for CERL_LD4L_CACHE
    #       ],
    #     CERL_NEW_LD4L_CACHE =
    #       [ { type: :accuracy_test,
    #           status: :PASS,
    #           authority_name: 'CERL_NEW_LD4L_CACHE',
    #           subauthority_name: 'imprint',
    #           service: 'ld4l_cache',
    #           action: 'search',
    #           url: '/qa/search/linked_data/cerl_new_ld4l_cache/imprint?q=Plantin&maxRecords=8',
    #           request_data: 'Plantin',
    #           expected: 1,
    #           actual: 1,
    #           target: 'http://thesaurus.cerl.org/record/cni00007649',
    #           err_message: '',
    #           request_run_time: 0.022,
    #           normalization_run_time: 0.011,
    #           pending: false },
    #           ... # all others for CERL_NEW_LD4L_CACHE
    #       ]
    #   }
    def filter(type: nil, group: false)
      return group_data(@log) if group && type.blank?
      return @log if type.blank?
      filtered_log = @log.select { |entry| entry[:type] == type }
      group ? group_data(filtered_log) : filtered_log
    end

    def group_data(log)
      grouped_data = {}
      log.each do |datum|
        auth_name = datum[:authority_name]
        grouped_data[auth_name] = [] unless grouped_data.key? auth_name
        grouped_data[auth_name] << datum
      end
      grouped_data
    end

    # @return the scenario test results data as an array
    def to_a
      @log
    end
  end
end
