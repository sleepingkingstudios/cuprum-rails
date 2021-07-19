# frozen_string_literal: true

require 'cuprum/rails/responses/html'

module Cuprum::Rails::Responses::Html
  # Encapsulates an HTML response that renders a given template.
  class RenderResponse
    # @param assigns [Hash] Variables to assign when rendering the template.
    # @param layout [String] The layout to render.
    # @param status [Integer] The HTTP status of the response.
    # @param template [String, Symbol] The template to render.
    def initialize(template, assigns: {}, layout: nil, status: 200)
      @assigns  = assigns
      @layout   = layout
      @status   = status
      @template = template
    end

    # @return [Hash] variables to assign when rendering the template.
    attr_reader :assigns

    # @return [String] the layout to render.
    attr_reader :layout

    # @return [Integer] the HTTP status of the response.
    attr_reader :status

    # @return [String, Symbol] the template to render.
    attr_reader :template

    # Calls the renderer's #render method with the template and parameters.
    #
    # @param renderer [#redirect_to] The context for executing the response,
    #   such as a Rails controller.
    def call(renderer)
      assign_variables(renderer)

      options = { status: status }
      options[:layout] = layout if layout

      renderer.render(template, **options)
    end

    private

    def assign_variables(renderer)
      assigns.each do |key, value|
        renderer.instance_variable_set("@#{key}", value)
      end
    end
  end
end
