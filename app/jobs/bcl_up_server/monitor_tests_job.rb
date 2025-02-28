# frozen_string_literal: true
# Job to run monitoring tests
module BclUpServer
  class MonitorTestsJob < ApplicationJob
    include BclUpServer::AuthorityValidationBehavior

    queue_as :default

    class_attribute :scenario_run_registry_class
    self.scenario_run_registry_class = BclUpServer::ScenarioRunRegistry

    def perform
      # checking active_job_id? prevents race conditions for long running jobs
      run_tests if BclUpServer::JobIdCache.active_job_id?(job_key:, job_id:, expires_in: 2.hours)
    end

  private

    def run_tests
      BclUpServer.config.monitor_logger.debug("(#{self.class}##{__method__}-#{job_id}) RUNNING monitoring tests")
      validate(authorities_list)
      log_results(authorities_list, status_log.to_a)
      scenario_run_registry_class.save_run(scenarios_results: status_log.to_a)
      BclUpServer.config.monitor_logger.debug("(#{self.class}##{__method__}-#{job_id}) COMPLETED monitoring tests")
      BclUpServer.config.performance_cache.write_all # write out cache after completing tests
      BclUpServer::JobIdCache.reset_job_id(job_key:)
    end

    def log_results(authorities_list, results)
      BclUpServer.config.monitor_logger.warn("(#{self.class}##{__method__}-#{job_id}) authorities_list is empty") if authorities_list&.empty?
      BclUpServer.config.monitor_logger.warn("(#{self.class}##{__method__}-#{job_id}) test results are empty") if results&.empty?
    end

    def job_key
      "BclUpServer::MonitorTestsJob--job_id"
    end
  end
end
