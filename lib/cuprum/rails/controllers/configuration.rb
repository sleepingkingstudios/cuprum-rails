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

    # @!method default_format
    #   @return [Symbol] the default format for controller requests.

    # @!method middleware
    #   @return [Array<Cuprum::Rails::Controllers::Middleware>] the middleware
    #     defined for the controller.

    # @!method repository
    #   @return [Cuprum::Collections::Repository] the repository containing the
    #     data collections for the application or scope.

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
      :default_format,
      :middleware,
      :repository,
      :resource,
      :responders,
      :serializers

    # Finds the configured middleware for the requested action name.
    #
    # @param request [Symbol] the request to match.
    #
    # @return [Array<Cuprum::Rails::Controllers::Middleware>] the configured
    #   middleware for the action.
    def middleware_for(request)
      middleware.select { |item| item.matches?(request) }
    end

    # Finds the configured responder for the requested format.
    #
    # @param format [Symbol] the format to respond to.
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

    # Finds the configured serializers for the requested format.
    #
    # @param format [Symbol] the format to respond to.
    #
    # @return [Hash<Class, Object>] the serializers for converting result values
    #   into serialized data.
    def serializers_for(format)
      serializers
        .select { |key, _| key.is_a?(Class) }
        .merge(serializers.fetch(format, {}))
    end
  end
end
