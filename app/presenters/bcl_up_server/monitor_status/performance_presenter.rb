# frozen_string_literal: true
# This presenter class provides performance data needed by the view that monitors status of authorities.
module BclUpServer::MonitorStatus
  class PerformancePresenter
    include BclUpServer::MonitorStatus::PerformanceDatatableBehavior
    include BclUpServer::MonitorStatus::PerformanceGraphBehavior
    include BclUpServer::PerformanceHistoryDataKeys

    # @param parent [BclUpServer::MonitorStatusPresenter] parent presenter
    # @param performance_data [Hash<Hash>] performance data
    def initialize(parent:, performance_data:)
      @parent = parent
      @performance_data = performance_data
    end

    attr_reader :performance_data

    def performance_data?
      performance_data.present?
    end

    def display_performance?
      display_performance_graph? || display_performance_datatable?
    end

    def display_performance_graph?
      BclUpServer.config.display_performance_graph? && !performance_graphs.nil? && !performance_graphs.empty?
    end

    def display_performance_datatable?
      BclUpServer.config.display_performance_datatable? && !performance_data.nil?
    end

    def performance_data_authority_name(entry)
      entry.keys.first
    end
  end
end
