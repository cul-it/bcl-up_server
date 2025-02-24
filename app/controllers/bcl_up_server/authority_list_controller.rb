# frozen_string_literal: true
# Controller for Authorities header menu item
module BCLUpServer
  class AuthorityListController < ApplicationController
    layout 'bcl_up_server'

    include BCLUpServer::AuthorityValidationBehavior

    class_attribute :presenter_class
    self.presenter_class = BCLUpServer::AuthorityListPresenter

    # Sets up presenter with data to display in the UI
    def index
      list(authorities_list)
      @presenter = presenter_class.new(urls_data: status_data_from_log)
    end
  end
end
