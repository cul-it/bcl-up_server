# frozen_string_literal: true
require 'bcl_up_server/engine'
require 'bcl_up_server/version'
require 'user_agent'
require 'deprecation'

module BclUpServer
  extend ActiveSupport::Autoload
  extend Deprecation

  self.deprecation_horizon = 'cul-it/BclUpServer v6.0.0'

  autoload :Configuration

  # @api public
  #
  # Exposes the Questioning Authority configuration
  #
  # @yield [Qa::Configuration] if a block is passed
  # @return [Qa::Configuration]
  # @see Qa::Configuration for configuration options
  def self.config(&block)
    puts "############# CONFIG ###############"
    @config ||= BclUpServer::Configuration.new
    puts "############# @config  ###############"
    puts @config

    yield @config if block

    @config
  end

  def self.log_agent_info(request)
    return if !Qa.config.respond_to?(:suppress_ip_data_from_log) || Qa.config.suppress_ip_data_from_log
    user_agent = request.respond_to?(:user_agent) && !request.user_agent.nil? ? ::UserAgent.parse(request.user_agent) : nil
    return Rails.logger.info("{browser: UNKNOWN, browser_version: UNKNOWN, platform: UNKNOWN, os: UNKNOWN}") if user_agent.nil?
    browser = user_agent.browser
    browser_version = user_agent.version
    platform = user_agent.platform
    os = user_agent.os
    Rails.logger.info("{browser: #{browser}, browser_version: #{browser_version}, platform: #{platform}, os: #{os}}")
  end
end
