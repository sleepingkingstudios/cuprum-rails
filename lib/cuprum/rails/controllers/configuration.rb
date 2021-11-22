# frozen_string_literal: true

require 'forwardable'

require 'cuprum/rails/controllers'

module Cuprum::Rails::Controllers
  # Data object that stores a controller's configuration.
  class Configuration
    extend Forwardable

    # @param controller [#resource, #responders] The controller to delegate
    #   configuration.
    def initialize(controller)
      @controller = controller
    end

    # @return [#resource, #responders] the controller to delegate configuration.
    attr_reader :controller

    # @!method controller_name
    #   @return [String] the name of the controller.

    # @!method middleware
    #   @return [Array<Cuprum::Rails::Controllers::Middleware>] the middleware
    #     defined for the controller.

    # @!method resource
    #   @return [Cuprum::Rails::Resource] the resource defined for the
    #     controller.

    # @!method responders
    #   @return [Hash<Symbol, Class>] the responder classes defined for the
    #     controller, by format.

    # @!method serializers
    #   @return [Hash<Class, Object>, Hash<Symbol, Hash<Class, Object>>] the
    #     serializers for converting result values into serialized data.

    def_delegators :@controller,
      :controller_name,
      :middleware,
      :resource,
      :responders,
      :serializers

    # Finds the configured middleware for the requested action name.
    #
    # @param action_name [Symbol] The name of the action.
    #
    # @return [Array<Cuprum::Rails::Controllers::Middleware>] the configured
    #   middleware for the action.
    def middleware_for(action_name)
      middleware.select { |item| item.matches?(action_name) }
    end

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
