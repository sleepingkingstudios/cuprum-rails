# frozen_string_literal: true

require 'pp'

require 'cuprum/rails/actions/middleware'

module Cuprum::Rails::Actions::Middleware
  # Configurable middleware for logging controller requests.
  class LogRequest < Cuprum::Command
    include Cuprum::Middleware

    DEFAULT_CONFIGURATION = {
      authorization: false,
      headers:       false,
      repository:    false,
      resource:      false
    }.freeze
    private_constant :DEFAULT_CONFIGURATION

    REQUEST_PROPERTIES = %i[
      action_name
      authorization
      body_params
      controller_name
      format
      headers
      http_method
      params
      path
      path_params
      query_params
    ].freeze
    private_constant :REQUEST_PROPERTIES

    # @param config [Hash] request and environment properties to log. A value of
    #   false will disable logging for that property.
    #
    # @option config action_name [Boolean] if true, logs the name of the action.
    #   Defaults to true.
    # @option config authorization [Boolean] if true, logs the value of the
    #   authorization header. Defaults to false.
    # @option config body_params [Boolean] if true, logs the parameters from the
    #   request body. Defaults to true.
    # @option config controller_name [Boolean] if true, logs the name of the
    #   controller. Defaults to true.
    # @option config format [Boolean] if true, logs the request format. Defaults
    #   to true.
    # @option config headers [Boolean] if true, logs the headers. Defaults to
    #   false.
    # @option config http_methopd [Boolean] if true, logs the request HTTP
    #   method. Defaults to true.
    # @option config params [Boolean] if true, logs the request parameters.
    #   Defaults to true.
    # @option config path [Boolean] if true, logs the request path. Defaults to
    #   true.
    # @option config path_params [Boolean] if true, logs the parameters from the
    #   request path. Defaults to true.
    # @option config query_params [Boolean] if true, logs the parameters from
    #   the url query. Defaults to true.
    # @option config repository [Boolean] if true, logs the repository used in
    #   the request. Defaults to false.
    # @option config resource [Boolean] if true, logs the resource used in the
    #   request. Defaults to false.
    def initialize(**config)
      super()

      @config = DEFAULT_CONFIGURATION.merge(config)
    end

    # @return [Hash] request and environment properties to log.
    attr_reader :config

    private

    def format_log(request:, **options)
      msg = "  #{self.class.name}#process"

      logged_properties(request:, **options).each do |label, formatted|
        msg << "\n    #{label}\n"
        msg << tools.string_tools.indent(formatted, 6)
      end

      msg
    end

    def log_property?(name)
      config.fetch(name.intern, true)
    end

    def logged_properties(request:, repository: nil, resource: nil, **options)
      hsh = {}

      if log_property?(:command_options) && options.present?
        hsh['Command Options'] = options.pretty_inspect
      end

      if log_property?(:repository)
        hsh['Repository'] = repository.pretty_inspect
      end

      hsh['Resource'] = resource.pretty_inspect if log_property?(:resource)

      hsh.merge(request_properties(request:))
    end

    def process(next_command, request:, **options)
      Rails.logger.info format_log(request:, **options)

      next_command.call(request:, **options)
    end

    def request_properties(request:)
      hsh = {}

      REQUEST_PROPERTIES.each do |key|
        next unless log_property?(key)

        hsh[key.to_s.titleize] = request.send(key).pretty_inspect
      end

      hsh
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
