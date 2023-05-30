# frozen_string_literal: true

require 'cuprum/rails/responses/html'

module Cuprum::Rails::Responses::Html
  # Encapsulates an HTML response that redirects to a given path.
  class RedirectResponse
    # @param flash [Hash] the flash messages to set.
    # @param path [String] the path or url to redirect to.
    # @param status [Integer] the HTTP status of the response.
    def initialize(path, flash: {}, status: 302)
      @flash  = flash
      @path   = path
      @status = status
    end

    # @return [Hash] the flash messages to set.
    attr_reader :flash

    # @return [String] the path or url to redirect to.
    attr_reader :path

    # @return [Integer] the HTTP status of the response.
    attr_reader :status

    # Calls the renderer's #redirect_to method with the path and status.
    #
    # @param renderer [#redirect_to] The tontext for executing the response,
    #   such as a Rails controller.
    def call(renderer)
      assign_flash(renderer)

      renderer.redirect_to(path, status: status)
    end

    private

    def assign_flash(renderer)
      flash.each do |key, value|
        renderer.flash[key] = value
      end
    end
  end
end
