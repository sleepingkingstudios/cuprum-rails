# frozen_string_literal: true

require 'cuprum/rails/responses'

module Cuprum::Rails::Responses
  # Encapsulates a response without a response body.
  class HeadResponse
    # @param status [Integer] the HTTP status of the response.
    def initialize(status:)
      @status = status
    end

    # @return [Integer] the HTTP status of the response.
    attr_reader :status

    # Calls the renderer's #head method with the configured status.
    #
    # @param renderer [#render] The context for executing the response, such as
    #   a Rails controller.
    def call(renderer)
      renderer.head(status)
    end
  end
end
