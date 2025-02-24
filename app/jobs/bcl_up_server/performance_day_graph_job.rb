# frozen_string_literal: true
# Job to generate the performance day graph covering the last 24 hours.
module BCLUpServer
  class PerformanceDayGraphJob < ApplicationJob
    include BCLUpServer::PerformanceHistoryDataKeys

    queue_as :default

    class_attribute :authority_list_class, :graph_data_service, :graphing_service
    self.authority_list_class = BCLUpServer::AuthorityListerService
    self.graph_data_service = BCLUpServer::PerformanceGraphDataService
    self.graphing_service = BCLUpServer::PerformanceGraphingService

    def perform
      # checking active_job_id? prevents race conditions for long running jobs
      generate_graphs_for_authorities if BCLUpServer::JobIdCache.active_job_id?(job_key: job_key, job_id: job_id)
    end

  private

    def generate_graphs_for_authorities
      BCLUpServer.config.monitor_logger.debug("(#{self.class}-#{job_id}) - GENERATING performance day graph")
      auths = authority_list_class.authorities_list
      generate_graphs_for_authority(authority_name: ALL_AUTH) # generates graph for all authorities
      auths.each { |authname| generate_graphs_for_authority(authority_name: authname) }
      BCLUpServer.config.monitor_logger.debug("(#{self.class}-#{job_id}) COMPLETED performance day graph generation")
      BCLUpServer::JobIdCache.reset_job_id(job_key: job_key)
    end

    def generate_graphs_for_authority(authority_name:)
      [SEARCH, FETCH, ALL_ACTIONS].each_with_object({}) do |action, hash|
        hash[action] = generate_24_hour_graph(authority_name: authority_name, action: action)
      end
    end

    def generate_24_hour_graph(authority_name:, action:)
      data = graph_data_service.calculate_last_24_hours(authority_name: authority_name, action: action)
      graphing_service.generate_day_graph(authority_name: authority_name, action: action, data: data)
    end

    def job_key
      "BCLUpServer::PerformanceDayGraphJob--job_id"
    end
  end
end
