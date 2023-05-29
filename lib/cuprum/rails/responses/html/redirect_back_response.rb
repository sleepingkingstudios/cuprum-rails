# frozen_string_literal: true

require 'cuprum/rails/responses/html'

module Cuprum::Rails::Responses::Html
  # Encapsulates an HTML response that redirects to the previous path.
  class RedirectBackResponse
    # @param fallback_location [String] the path or url to redirect to if the
    #   previous location cannot be determined.
    # @param status [Integer] the HTTP status of the response.
    def initialize(fallback_location: '/', status: 302)
      @fallback_location = fallback_location
      @status            = status
    end

    # @return [String] the path or url to redirect to if the previous location
    #   cannot be determined.
    attr_reader :fallback_location

    # @return [Integer] the HTTP status of the response.
    attr_reader :status

    # Calls the renderer's #redirect_back_or_to method with the status.
    #
    # @param renderer [#redirect_back_or_to] the context for executing the
    #   response, such as a Rails controller.
    def call(renderer)
      renderer.redirect_back_or_to(fallback_location, status: status)
    end
  end
end
