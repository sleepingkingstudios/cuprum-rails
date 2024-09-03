# frozen_string_literal: true

require 'cuprum/rails/responses/html'

module Cuprum::Rails::Responses::Html
  # Encapsulates an HTML response that redirects to the previous path.
  class RedirectBackResponse
    # @param fallback_location [String] the path or url to redirect to if the
    #   previous location cannot be determined.
    # @param flash [Hash] the flash messages to set.
    # @param status [Integer] the HTTP status of the response.
    def initialize(fallback_location: '/', flash: {}, status: 302)
      @fallback_location = fallback_location
      @flash             = flash
      @status            = status
    end

    # @return [String] the path or url to redirect to if the previous location
    #   cannot be determined.
    attr_reader :fallback_location

    # @return [Hash] the flash messages to set.
    attr_reader :flash

    # @return [Integer] the HTTP status of the response.
    attr_reader :status

    # Calls the renderer's #redirect_back_or_to method with the status.
    #
    # @param renderer [#redirect_back_or_to] the context for executing the
    #   response, such as a Rails controller.
    def call(renderer)
      assign_flash(renderer)

      # :nocov:
      if Rails.version >= '7.0' # @todo Rails 6
        renderer.redirect_back_or_to(fallback_location, status:)
      else
        renderer.redirect_back(
          fallback_location:,
          status:
        )
      end
      # :nocov:
    end

    private

    def assign_flash(renderer)
      flash.each do |key, value|
        renderer.flash[key] = value
      end
    end
  end
end
