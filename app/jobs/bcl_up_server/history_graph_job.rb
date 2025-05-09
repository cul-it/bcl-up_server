# frozen_string_literal: true
# Job to generate the graph of historical test runs per authority.
module BclUpServer
  class HistoryGraphJob < ApplicationJob
    queue_as :default

    class_attribute :graphing_service
    self.graphing_service = BclUpServer::HistoryGraphingService

    def perform(data:)
      # checking active_job_id? prevents race conditions for long running jobs
      generate_graph(data) if BclUpServer::JobIdCache.active_job_id?(job_key:, job_id:)
    end

  private

    def generate_graph(data)
      BclUpServer.config.monitor_logger.debug("(#{self.class}##{__method__}-#{job_id}) - GENERATING historical summary graph")
      graphing_service.generate_graph(data)
      BclUpServer.config.monitor_logger.debug("(#{self.class}##{__method__}-#{job_id}) COMPLETED historical summary graph generation")
      BclUpServer::JobIdCache.reset_job_id(job_key:)
    end

    def job_key
      "BclUpServer::HistoryGraphJob--job_id"
    end
  end
end
