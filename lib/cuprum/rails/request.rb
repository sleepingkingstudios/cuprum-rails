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
          method:          request.request_method_symbol,
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
    end

    # @param action_name [Symbol] The name of the called action.
    # @param authorization [String, nil] The authorization header, if any.
    # @param body_params [Hash<String, Object>] The parameters from the request
    #   body.
    # @param controller_name [String] The name of the controller.
    # @param format [Symbol] The request format, e.g. :html or :json.
    # @param headers [Hash<String, String>] The request headers.
    # @param method [Symbol] The HTTP method used for the request.
    # @param params [Hash<String, Object>] The merged GET and POST parameters.
    # @param query_params [Hash<String, Object>] The query parameters.
    def initialize( # rubocop:disable Metrics/ParameterLists
      body_params:,
      format:,
      headers:,
      method:,
      params:,
      path:,
      query_params:,
      action_name:     nil,
      authorization:   nil,
      controller_name: nil
    )
      @action_name     = action_name
      @authorization   = authorization
      @controller_name = controller_name
      @body_params     = body_params
      @format          = format
      @headers         = headers
      @method          = method
      @path            = path
      @params          = params
      @query_params    = query_params
    end

    # @return [Symbol] the name of the called action.
    attr_reader :action_name

    # @return [String, nil] the authorization header, if any.
    attr_reader :authorization

    # @return [Hash<String, Object>] The parameters from the request body.
    attr_reader :body_params
    alias body_parameters body_params

    # @return [String] the name of the controller.
    attr_reader :controller_name

    # @return [Symbol] the request format, e.g. :html or :json.
    attr_reader :format

    # @return [Hash<String, String>] the request headers.
    attr_reader :headers

    # @return [Symbol] the HTTP method used for the request.
    attr_reader :method

    # @return [Hash<String, Object>] The merged GET and POST parameters.
    attr_reader :params
    alias parameters params

    # @return [String] the relative path of the request, including params.
    attr_reader :path

    # @return [Hash<String, Object>] the query parameters.
    attr_reader :query_params
    alias query_parameters query_params
  end
end
