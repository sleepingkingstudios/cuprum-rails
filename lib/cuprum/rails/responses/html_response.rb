# frozen_string_literal: true

require 'cuprum/rails/responses'

module Cuprum::Rails::Responses
  # Encapsulates an HTML response that renders a given HTML string.
  class HtmlResponse
    # @param html [String, ActiveSupport::SafeBuffer] the HTML to render.
    # @param layout [String, Symbol, true, false] the layout to render. If true,
    #   renders the default layout for the controller. If false, does not render
    #   a layout. Defaults to true.
    # @param status [Integer] the HTTP status of the response.
    def initialize(html:, layout: true, status: 200)
      @html   = html
      @layout = layout
      @status = status
    end

    # @return [String, ActiveSupport::SafeBuffer] the HTML to render.
    attr_reader :html

    # @return [String, Symbol, true, false] the layout to render. If true,
    #   renders the default layout for the controller. If false, does not render
    #   a layout. Defaults to true.
    attr_reader :layout

    # @return [Integer] the HTTP status of the response.
    attr_reader :status

    # Calls the renderer's #render method with the serialized data and status.
    #
    # @param renderer [#render] The context for executing the response, such as
    #   a Rails controller.
    def call(renderer)
      renderer.render(html:, layout:, status:)
    end
  end
end
