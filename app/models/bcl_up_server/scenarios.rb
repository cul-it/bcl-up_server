# frozen_string_literal: true
# Holds all scenarios for an authority.
module BclUpServer
  class Scenarios
    AUTHORITY_SCENARIO = 'authority'
    TERM_SCENARIOS = 'term'
    SEARCH_SCENARIOS = 'search'

    # @return [Qa::Authorities::LinkedData::GenericAuthority] authority instance the scenarios run against
    attr_reader :authority

    # @return [String] name of the authority the scenarios run against (e.g. 'agrovoc_direct')
    attr_reader :authority_name

    # @return [Array<TermScenario>] the term scenarios to run against the authority
    attr_reader :term_scenarios

    # @return [Array<SearchScenario>] the search scenarios to run against the authority
    attr_reader :search_scenarios

    # @return [Hash] configurations from the yml file for all scenarios for an authority
    attr_reader :scenarios_config; private :scenarios_config # rubocop:disable Style/Semicolon

    # @param authority [Qa::Authorities::LinkedData::GenericAuthority] the instance of the QA authority
    # @param authoity_name [String] the name of the authority the scenario tests (e.g. "agrovoc_direct")
    # @param scenarios_config [Hash] configurations from the yml file for all scenarios for an authority
    def initialize(authority:, authority_name:, scenarios_config:)
      @authority = authority
      @authority_name = authority_name
      @scenarios_config = scenarios_config
      parse_term_scenarios
      parse_search_scenarios
    end

  private

    def parse_term_scenarios
      @term_scenarios = []
      term_scenarios_config.each do |term_scenario_config|
        @term_scenarios << BclUpServer::TermScenario.new(authority:,
                                                         authority_name:,
                                                         authority_scenario_config:,
                                                         scenario_config: term_scenario_config)
      end
    end

    def parse_search_scenarios
      @search_scenarios = []
      search_scenarios_config.each do |search_scenario_config|
        @search_scenarios << BclUpServer::SearchScenario.new(authority:,
                                                             authority_name:,
                                                             authority_scenario_config:,
                                                             scenario_config: search_scenario_config)
      end
    end

    def authority_scenario_config
      scenarios_config[AUTHORITY_SCENARIO]
    end

    def term_scenarios_config
      scenarios_config[TERM_SCENARIOS] || []
    end

    def search_scenarios_config
      scenarios_config[SEARCH_SCENARIOS] || []
    end
  end
end
