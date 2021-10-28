# frozen_string_literal: true

require 'cuprum/rails/responses'

module Cuprum::Rails::Responses
  # Encapsulates a JSON response that returns the given serialized data.
  class JsonResponse
    # @param data [Object] The JSON data to return.
    # @param status [Integer] The HTTP status of the response.
    def initialize(data:, status: 200)
      @data   = data
      @status = status
    end

    # @return [Object] the JSON data to return.
    attr_reader :data

    # @return [Integer] the HTTP status of the response.
    attr_reader :status

    # Calls the renderer's #render method with the serialized data and status.
    #
    # @param renderer [#render] The context for executing the response, such as
    #   a Rails controller.
    def call(renderer)
      renderer.render(json: data, status: status)
    end
  end
end
