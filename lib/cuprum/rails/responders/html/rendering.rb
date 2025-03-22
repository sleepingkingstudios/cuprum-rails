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
      Cuprum::Rails::Responses::HeadResponse.new(status:)
    end

    # Creates a RedirectBackResponse based on the given HTTP status.
    #
    # @param fallback_location [String] the path or url to redirect to if the
    #   previous location cannot be determined.
    # @param flash [Hash] the flash messages to set.
    # @param status [Integer] the HTTP status of the response.
    def redirect_back(fallback_location: '/', flash: {}, status: 302)
      Cuprum::Rails::Responses::Html::RedirectBackResponse
        .new(fallback_location:, flash:, status:)
    end

    # Creates a RedirectResponse based on the given path and HTTP status.
    #
    # @param flash [Hash] the flash messages to set.
    # @param path [String] the path or url to redirect to.
    # @param status [Integer] the HTTP status of the response.
    #
    # @return [Cuprum::Rails::Responses::Html::RedirectResponse] the response.
    def redirect_to(path, flash: {}, status: 302)
      Cuprum::Rails::Responses::Html::RedirectResponse
        .new(path, flash:, status:)
    end

    # Creates a RenderResponse based on the given template and parameters.
    #
    # @param assigns [Hash] variables to assign when rendering the template.
    # @param flash [Hash] the flash messages to set.
    # @param layout [String] the layout to render.
    # @param status [Integer] the HTTP status of the response.
    # @param template [String, Symbol] the template to render.
    #
    # @return [Cuprum::Rails::Responses::Html::RenderResponse] the response.
    def render(template, assigns: nil, flash: {}, layout: nil, status: 200)
      Cuprum::Rails::Responses::Html::RenderResponse.new(
        template,
        assigns: assigns || default_assigns,
        flash:,
        layout:  resolve_layout(layout),
        status:
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

    def resolve_layout(layout)
      return layout if layout.present?

      return false if turbo_stream_request?

      return turbo_frame_layout if turbo_frame_request?

      nil
    end

    def turbo_frame_layout
      'turbo_rails/frame'
    end

    def turbo_frame_request?
      request.headers['HTTP_TURBO_FRAME'].present?
    end

    def turbo_stream_request?
      request.format.to_s == 'turbo_stream'
    end
  end
end
