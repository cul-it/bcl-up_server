# frozen_string_literal: true
# Provide service methods for getting a list of all authorities and scenarios for an authority.
module BclUpServer
  class AuthorityListerService
    # Return a list of supported authorities
    # @return [Array<String>] list of authorities
    def self.authorities_list
      Qa::LinkedData::AuthorityService.authority_names
    end

    # Fill in status_log with data about each scenario for an authority
    # @param authority_name [String] the name of the authority
    # @param status_log [ScenarioLogger] the log that will hold the data about the scenarios
    def self.scenarios_list(authority_name:, status_log:)
      scenarios = BclUpServer::ScenariosLoaderService.load(authority_name:, status_log:)
      return if scenarios.blank?
      list_terms(scenarios, status_log)
      list_searches(scenarios, status_log)
    end

    def self.list_terms(scenarios, status_log)
      scenarios.term_scenarios.each { |scenario| BclUpServer::TermScenarioValidator.new(scenario:, status_log:).log_without_running }
    end
    private_class_method :list_terms

    def self.list_searches(scenarios, status_log)
      scenarios.search_scenarios.each { |scenario| BclUpServer::SearchScenarioValidator.new(scenario:, status_log:).log_without_running }
    end
    private_class_method :list_searches
  end
end
