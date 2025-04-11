# frozen_string_literal: true
# Job to generate the performance day graph covering the last 24 hours.
module BclUpServer
  class PerformanceDayGraphJob < ApplicationJob
    include BclUpServer::PerformanceHistoryDataKeys

    queue_as :default

    class_attribute :authority_list_class, :graph_data_service, :graphing_service
    self.authority_list_class = BclUpServer::AuthorityListerService
    self.graph_data_service = BclUpServer::PerformanceGraphDataService
    self.graphing_service = BclUpServer::PerformanceGraphingService

    def perform
      # checking active_job_id? prevents race conditions for long running jobs
      generate_graphs_for_authorities if BclUpServer::JobIdCache.active_job_id?(job_key:, job_id:)
    end

  private

    def generate_graphs_for_authorities
      BclUpServer.config.monitor_logger.debug("(#{self.class}-#{job_id}) - GENERATING performance day graph")
      auths = authority_list_class.authorities_list
      generate_graphs_for_authority(authority_name: ALL_AUTH) # generates graph for all authorities
      auths.each { |authname| generate_graphs_for_authority(authority_name: authname) }
      BclUpServer.config.monitor_logger.debug("(#{self.class}-#{job_id}) COMPLETED performance day graph generation")
      BclUpServer::JobIdCache.reset_job_id(job_key:)
    end

    def generate_graphs_for_authority(authority_name:)
      [SEARCH, FETCH, ALL_ACTIONS].each_with_object({}) do |action, hash|
        hash[action] = generate_24_hour_graph(authority_name:, action:)
      end
    end

    def generate_24_hour_graph(authority_name:, action:)
      data = graph_data_service.calculate_last_24_hours(authority_name:, action:)
      graphing_service.generate_day_graph(authority_name:, action:, data:)
    end

    def job_key
      "BclUpServer::PerformanceDayGraphJob--job_id"
    end
  end
end
