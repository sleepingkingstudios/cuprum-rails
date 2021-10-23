# frozen_string_literal: true

require 'cuprum/rails/controllers'

module Cuprum::Rails::Controllers
  # Data object that stores a controller's configuration.
  class Configuration
    # @param resource [Cuprum::Rails::Resource] The resource defined for the
    #   controller.
    # @param responders [Hash<Symbol, Class>] The responder classes defined for
    #   the controller, by format.
    def initialize(resource:, responders:)
      @resource   = resource
      @responders = responders
    end

    # @return [Cuprum::Rails::Resource] the resource defined for the
    #   controller.
    attr_reader :resource

    # @return [Hash<Symbol, Class>] the responder classes defined for the
    #   controller, by format.
    attr_reader :responders

    # Finds the configured responder for the requested format.
    #
    # @param format [Symbol] The format to respond to.
    #
    # @return [Class] the responder class defined for the format.
    #
    # @raise [Cuprum::Rails::Controller::UnknownFormatError] if the controller
    #   does not define a responder for the given format.
    def responder_for(format)
      responders.fetch(format) do
        raise Cuprum::Rails::Controller::UnknownFormatError,
          "no responder registered for format #{format.inspect}"
      end
    end
  end
end
