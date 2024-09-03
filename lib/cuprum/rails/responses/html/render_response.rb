# frozen_string_literal: true

require 'cuprum/rails/responses/html'

module Cuprum::Rails::Responses::Html
  # Encapsulates an HTML response that renders a given template.
  class RenderResponse
    # @param assigns [Hash] variables to assign when rendering the template.
    # @param flash [Hash] the flash messages to set.
    # @param layout [String] the layout to render.
    # @param status [Integer] the HTTP status of the response.
    # @param template [String, Symbol] the template to render.
    def initialize(template, assigns: {}, flash: {}, layout: nil, status: 200)
      @assigns  = assigns
      @flash    = flash
      @layout   = layout
      @status   = status
      @template = template
    end

    # @return [Hash] variables to assign when rendering the template.
    attr_reader :assigns

    # @return [Hash] the flash messages to set.
    attr_reader :flash

    # @return [String] the layout to render.
    attr_reader :layout

    # @return [Integer] the HTTP status of the response.
    attr_reader :status

    # @return [String, Symbol] the template to render.
    attr_reader :template

    # Calls the renderer's #render method with the template and parameters.
    #
    # @param renderer [#render] The context for executing the response, such as
    #   a Rails controller.
    def call(renderer)
      assign_flash(renderer)
      assign_variables(renderer)

      options = { status: }
      options[:layout] = layout if layout

      renderer.render(template, **options)
    end

    private

    def assign_flash(renderer)
      flash.each do |key, value|
        renderer.flash.now[key] = value
      end
    end

    def assign_variables(renderer)
      assigns.each do |key, value|
        renderer.instance_variable_set("@#{key}", value)
      end
    end
  end
end
