# frozen_string_literal: true

require 'cuprum/rails/responders/html'

module Cuprum::Rails::Responders::Html
  # Implements generating HTML response objects.
  module Rendering
    # Creates a HeadResponse based on the given HTTP status.
    #
    # @param status [Integer] the HTTP status of the response.
    #
    # @return [Cuprum::Rails::Responses::HeadResponse] the response.
    def head(status:)
      Cuprum::Rails::Responses::HeadResponse.new(status: status)
    end

    # Creates a RedirectBackResponse based on the given HTTP status.
    #
    # @param fallback_location [String] the path or url to redirect to if the
    #   previous location cannot be determined.
    # @param status [Integer] the HTTP status of the response.
    def redirect_back(fallback_location: '/', status: 302)
      Cuprum::Rails::Responses::Html::RedirectBackResponse
        .new(fallback_location: fallback_location, status: status)
    end

    # Creates a RedirectResponse based on the given path and HTTP status.
    #
    # @param path [String] the path or url to redirect to.
    # @param status [Integer] the HTTP status of the response.
    #
    # @return [Cuprum::Rails::Responses::Html::RedirectResponse] the response.
    def redirect_to(path, status: 302)
      Cuprum::Rails::Responses::Html::RedirectResponse.new(path, status: status)
    end

    # Creates a RenderResponse based on the given template and parameters.
    #
    # @param assigns [Hash] variables to assign when rendering the template.
    # @param layout [String] the layout to render.
    # @param status [Integer] the HTTP status of the response.
    # @param template [String, Symbol] the template to render.
    #
    # @return [Cuprum::Rails::Responses::Html::RenderResponse] the response.
    def render(template, assigns: nil, layout: nil, status: 200)
      Cuprum::Rails::Responses::Html::RenderResponse.new(
        template,
        assigns: assigns || default_assigns,
        layout:  layout,
        status:  status
      )
    end

    private

    def default_assigns
      return nil if result.nil?

      assigns = default_value

      assigns[:error] = result.error unless result.error.nil?

      assigns
    end

    def default_value
      if result.value.is_a?(Hash)
        result.value
      elsif !result.value.nil?
        { value: result.value }
      else
        {}
      end
    end
  end
end
