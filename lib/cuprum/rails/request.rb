# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Wraps a web request with a generic interface.
  class Request
    class << self
      FILTERED_HEADER_PREFIXES = %w[
        action_
        puma
        rack
      ].freeze
      private_constant :FILTERED_HEADER_PREFIXES

      # Generates a Request from a native Rails request.
      #
      # @param request [ActionDispatch::Request] The native request to build.
      #
      # @return [Cuprum::Rails::Request] the generated request.
      def build(request:, **options) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        body_params  = request.request_parameters
        query_params = request.query_parameters
        path_params  = filter_path_parameters(request.path_parameters)

        new(
          action_name:     request.params['action']&.intern,
          authorization:   request.authorization,
          body_params:     body_params,
          controller_name: request.params['controller'],
          format:          request.format.symbol,
          headers:         filter_headers(request.headers),
          http_method:     request.request_method_symbol,
          params:          body_params.merge(query_params).merge(path_params),
          path:            request.fullpath,
          path_params:     path_params,
          query_params:    query_params,
          **options
        )
      end

      private

      def filter_headers(headers)
        headers.reject do |key, _|
          FILTERED_HEADER_PREFIXES.any? { |prefix| key.start_with?(prefix) }
        end
      end

      def filter_path_parameters(path_parameters)
        path_parameters.except('action', 'controller')
      end

      def property(property_name)
        define_method(property_name) do
          @properties[property_name]
        end

        define_method(:"#{property_name}=") do |value|
          @properties[property_name] = value
        end
      end
    end

    # @param context [Object] the controller or request context.
    #
    # @option properties [Symbol] :action_name the name of the called action.
    # @option properties [String, nil] :authorization the authorization header,
    #   if any.
    # @option properties [Hash<String, Object>] :body_params the parameters from
    #   the request body.
    # @option properties [String] :controller_name the name of the controller.
    # @option properties [Symbol] :format the request format, e.g. :html or
    #   :json.
    # @option properties [Hash<String, String>] :headers the request headers.
    # @option properties [Symbol] :method the HTTP method used for the request.
    # @option properties [Hash<String, Object>] :params the merged GET and POST
    #   parameters.
    # @option properties [Hash<String, Object>] :query_params the query
    #   parameters.
    def initialize(context: nil, **properties)
      @context    = context
      @properties = properties
    end

    # @return [Object] the controller or request context.
    attr_reader :context

    # @return [Hash<Symbol, Object>] the properties of the request.
    attr_reader :properties

    # @!attribute action_name
    #   @return [Symbol] the name of the called action.
    property :action_name

    # @!attribute authorization
    #   @return [String, nil] the authorization header, if any.
    property :authorization

    # @!attribute body_params
    #   @return [Hash<String, Object>] the parameters from the request body.
    property :body_params
    alias body_parameters  body_params
    alias body_parameters= body_params=

    # @!attribute controller_name
    #   @return [String] the name of the controller.
    property :controller_name

    # @!attribute format [Symbol]
    #   @return the request format, e.g. :html or :json.
    property :format

    # @!attribute headers
    #   @return [Hash<String, String>] the request headers.
    property :headers

    # @!attribute method
    #   @return [Symbol] the HTTP method used for the request.
    property :http_method

    # @!attribute params
    #   @return [Hash<String, Object>] The merged GET and POST parameters.
    property :params
    alias parameters  params
    alias parameters= params=

    # @!attribute path
    #   @return [String] the relative path of the request, including params.
    property :path

    # @!attribute path_params
    #   @return [Hash<String, Object>] the path parameters.
    property :path_params
    alias path_parameters  path_params
    alias path_parameters= path_params=

    # @!attribute query_params
    #   @return [Hash<String, Object>] the query parameters.
    property :query_params
    alias query_parameters  query_params
    alias query_parameters= query_params=

    # @param property_name [String, Symbol] the name of the property.
    #
    # @return [Object] the value of the property
    def [](property_name)
      validate_property_name!(property_name)

      @properties[property_name.intern]
    end

    # @param property_name [String, Symbol] the name of the property.
    # @param value [Object] the value to assign to the property.
    def []=(property_name, value)
      validate_property_name!(property_name)

      @properties[property_name.intern] = value
    end

    # @return [ActionDispatch::Request::Session] the native session object.
    def native_session
      context&.session
    end

    private

    def validate_property_name!(name) # rubocop:disable Metrics/MethodLength
      if name.nil?
        raise ArgumentError,
          "property name can't be blank",
          caller(1..-1)
      end

      unless name.is_a?(String) || name.is_a?(Symbol)
        raise ArgumentError,
          'property name must be a String or a Symbol',
          caller(1..-1)
      end

      return unless name.empty?

      raise ArgumentError, "property name can't be blank", caller(1..-1)
    end
  end
end
