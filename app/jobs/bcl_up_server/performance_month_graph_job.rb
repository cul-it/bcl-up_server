# frozen_string_literal: true
# Job to generate the performance month graph covering the last 30 days.
module BclUpServer
  class PerformanceMonthGraphJob < ApplicationJob
    include BclUpServer::PerformanceHistoryDataKeys

    queue_as :default

    class_attribute :authority_list_class, :graph_data_service, :graphing_service
    self.authority_list_class = BclUpServer::AuthorityListerService
    self.graph_data_service = BclUpServer::PerformanceGraphDataService
    self.graphing_service = BclUpServer::PerformanceGraphingService

    def perform
      # checking active_job_id? prevents race conditions for long running jobs
      generate_graphs_for_authorities if BclUpServer::JobIdCache.active_job_id?(job_key: job_key, job_id: job_id)
    end

  private

    def generate_graphs_for_authorities
      BclUpServer.config.monitor_logger.debug("(#{self.class}-#{job_id}) - GENERATING performance month graph")
      auths = authority_list_class.authorities_list
      generate_graphs_for_authority(authority_name: ALL_AUTH) # generates graph for all authorities
      auths.each { |authname| generate_graphs_for_authority(authority_name: authname) }
      BclUpServer.config.monitor_logger.debug("(#{self.class}-#{job_id}) COMPLETED performance month graph generation")
      BclUpServer::JobIdCache.reset_job_id(job_key: job_key)
    end

    def generate_graphs_for_authority(authority_name:)
      [SEARCH, FETCH, ALL_ACTIONS].each_with_object({}) do |action, hash|
        hash[action] = generate_30_day_graph(authority_name: authority_name, action: action)
      end
    end

    def generate_30_day_graph(authority_name:, action:)
      data = graph_data_service.calculate_last_30_days(authority_name: authority_name, action: action)
      graphing_service.generate_month_graph(authority_name: authority_name, action: action, data: data)
    end

    def job_key
      "BclUpServer::PerformanceMonthGraphJob--job_id"
    end
  end
end
