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

      FILTERED_PARAMS = %w[controller action].freeze
      private_constant :FILTERED_PARAMS

      # Generates a Request from a native Rails request.
      #
      # @param request [] The native request to build.
      # @param action_name [Symbol] The name of the called action.
      # @param controller_name [String] The name of the controller.
      #
      # @return [Cuprum::Rails::Request] the generated request.
      def build(request:, action_name: nil, controller_name: nil) # rubocop:disable Metrics/MethodLength
        new(
          action_name:     action_name,
          authorization:   request.authorization,
          body_params:     request.request_parameters,
          controller_name: controller_name,
          format:          request.format.symbol,
          headers:         filter_headers(request.headers),
          http_method:     request.request_method_symbol,
          params:          filter_params(request.params),
          path:            request.fullpath,
          query_params:    request.query_parameters
        )
      end

      private

      def filter_headers(headers)
        headers.reject do |key, _|
          FILTERED_HEADER_PREFIXES.any? { |prefix| key.start_with?(prefix) }
        end
      end

      def filter_params(params)
        params.reject { |key, _| FILTERED_PARAMS.include?(key) }
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

    # @option properties [Symbol] :action_name The name of the called action.
    # @option properties [String, nil] :authorization The authorization header,
    #   if any.
    # @option properties [Hash<String, Object>] :body_params The parameters from
    #   the request body.
    # @option properties [String] :controller_name The name of the controller.
    # @option properties [Symbol] :format The request format, e.g. :html or
    #   :json.
    # @option properties [Hash<String, String>] :headers The request headers.
    # @option properties [Symbol] :method The HTTP method used for the request.
    # @option properties [Hash<String, Object>] :params The merged GET and POST
    #   parameters.
    # @option properties [Hash<String, Object>] :query_params The query
    #   parameters.
    def initialize(**properties)
      @properties = properties
    end

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

    # @!attribute query_params
    #   @return [Hash<String, Object>] the query parameters.
    property :query_params
    alias query_parameters  query_params
    alias query_parameters= query_params=

    # @param property_name [String, Symbol] The name of the property.
    #
    # @return [Object] the value of the property
    def [](property_name)
      validate_property_name!(property_name)

      @properties[property_name.intern]
    end

    # @param property_name [String, Symbol] The name of the property.
    # @param value [Object] The value to assign to the property.
    def []=(property_name, value)
      validate_property_name!(property_name)

      @properties[property_name.intern] = value
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
