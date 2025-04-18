# frozen_string_literal: true
# This class loads scenario configuration file for an authority.
module BclUpServer
  class ScenariosLoaderService
    # Load scenarios for testing an authority
    # @param authority_name [String] name of the authority to load (e.g. "agrovoc_direct")
    # @param status_log [ScenarioLogger] logger to hold failure information if the scenarios cannot be loaded
    # @return [Scenarios] the instance of the set of scenarios to test for the authority OR nil if fails to load
    def self.load(authority_name:, status_log:)
      begin
        authority = load_authority(authority_name, status_log)
        return nil if authority.blank?
        return nil unless scenarios_exist?(authority_name, status_log)

        scenarios_config = load_config(authority_name, status_log)
        return nil if scenarios_config.blank?

        scenarios = BclUpServer::Scenarios.new(authority:, authority_name:, scenarios_config:)
      rescue Exception => e
        status_log.add(authority_name:,
                       status: BclUpServer::ScenarioValidator::FAIL,
                       error_message: "Unable to load scenarios for authority '#{authority_name}'; cause: #{e.message}")
        return nil
      end
      scenarios
    end

    def self.load_authority(authority_name, status_log)
      BclUpServer::AuthorityLoaderService.load(authority_name:, status_log:)
    end
    private_class_method :load_authority

    def self.load_config(authority_name, status_log)
      scenarios_config = YAML.load_file(scenario_path(authority_name))
      if scenarios_config.blank?
        status_log.add(authority_name:,
                       status: BclUpServer::ScenarioValidator::FAIL,
                       error_message: "Unable to load scenarios for authority '#{authority_name}'; cause: UNKNOWN")
        return nil
      end
      scenarios_config
    end
    private_class_method :load_config

    def self.scenarios_exist?(authority_name, status_log)
      return true if File.exist?(scenario_path(authority_name))
      status_log.add(authority_name:,
                     status: BclUpServer::ScenarioValidator::FAIL,
                     error_message: "Unable to load scenarios for authority '#{authority_name}'; cause: #{scenario_path} does not exist.")
      false
    end
    private_class_method :scenarios_exist?

    def self.scenario_path(authority_name)
      File.join(::Rails.root, 'config', 'authorities', 'linked_data', 'scenarios', "#{authority_name.downcase}_validation.yml")
    end
    private_class_method :scenario_path
  end
end
