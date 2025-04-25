# frozen_string_literal: true
# This presenter class provides all data needed by the view that show the list of authorities.
module BclUpServer
  class NavmenuPresenter
    include BclUpServer::Engine.routes.url_helpers

    # @return [Array<Hash>] label-url pairs for the navigation bar's menu items justified left
    # @example
    #   [
    #     { label: 'Home', url: '/' },
    #     { label: 'Usage', url: '/usage' },
    #     { label: 'Authorities', url: '/authorities' },
    #     { label: 'Check Status', url: '/check_status' },
    #     { label: 'Monitor Status', url: '/monitor_status' }
    #   ]
    attr_reader :leftmenu_items

    def initialize
      @leftmenu_items = []
      @leftmenu_items << { label: I18n.t("bcl_up_server.menu.home"), url: root_path }
      @leftmenu_items << { label: I18n.t("bcl_up_server.menu.usage"), url: usage_index_path }
      @leftmenu_items << { label: I18n.t("bcl_up_server.menu.authorities"), url: authority_list_index_path }
      @leftmenu_items << { label: I18n.t("bcl_up_server.menu.check_status"), url: check_status_index_path }
      @leftmenu_items << { label: I18n.t("bcl_up_server.menu.monitor_status"), url: monitor_status_index_path }
      @leftmenu_items << { label: I18n.t("bcl_up_server.menu.fetch_term"), url: fetch_index_path }
    end

    # Append additional left justified menu items to the main navigation menu
    def append_leftmenu_items(additional_items = [])
      return if additional_items.nil?
      additional_items.each { |item| @leftmenu_items << item }
    end
  end
end
