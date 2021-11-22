# frozen_string_literal: true

require 'forwardable'

require 'cuprum/middleware'

require 'cuprum/rails/controllers'

module Cuprum::Rails::Controllers
  # @api private
  #
  # Implements a controller action.
  #
  # @note This class should not be initialized directly. Instead, use the
  #   Cuprum::Rails::Controller.action class method to define an action.
  class Action
    extend Forwardable

    # @param configuration [Cuprum::Rails::Controllers::Configuration] the
    #   configuration for the originating controller.
    # @param action_class [Class] The class of the action command. Must be
    #   constructible with keyword :resource.
    # @param action_name [String, Symbol] The name of the action.
    # @param member_action [Boolean] True if the action acts on a collection
    #   item, not on the collection as a whole.
    # @param serializers
    #   [Hash<Class, Object>, Hash<Symbol, Hash<Class, Object>>] The serializers
    #   for converting result values into serialized data.
    def initialize(
      configuration,
      action_class:,
      action_name:,
      member_action: false,
      serializers:   {}
    )
      @configuration = configuration
      @action_class  = action_class
      @action_name   = action_name
      @member_action = !!member_action # rubocop:disable Style/DoubleNegation
      @serializers   = serializers
    end

    # @return [Class] the class of the action command.
    attr_reader :action_class

    # @return [String, Symbol] the name of the action.
    attr_reader :action_name

    # @return [Cuprum::Rails::Controllers::Configuration] the configuration for
    #   the originating controller.
    attr_reader :configuration

    # @return [Hash<Class, Object>, Hash<Symbol, Hash<Class, Object>>] the
    #   serializers for converting result values into serialized data.
    attr_reader :serializers

    # @!method resource
    #   @return [Cuprum::Rails::Resource] the resource defined for the
    #     controller.

    # @!method responder_for(format)
    #   Finds the configured responder for the requested format.
    #
    #   @param format [Symbol] The format to respond to.
    #
    #   @return [Class] the responder class defined for the format.
    #
    #   @raise [Cuprum::Rails::Controller::UnknownFormatError] if the controller
    #     does not define a responder for the given format.

    def_delegators :@configuration,
      :resource,
      :responder_for

    # Executes the controller action.
    #
    # 1. Initializes the action command with the resource.
    # 2. Calls the command with the request.
    # 3. Builds the responder with the resource and action metadata.
    # 4. Calls the responder with the action result.
    #
    # @param request [Cuprum::Rails::Request] The request to process.
    #
    # @return [#call] The response object.
    def call(request)
      responder = build_responder(request)
      action    = action_class.new(resource: resource)
      action    = apply_middleware(action)
      result    = action.call(request: request)

      responder.call(result)
    end

    # @return [Boolean] true if the action acts on a collection item, not on the
    #   collection as a whole.
    def member_action?
      @member_action
    end

    private

    def apply_middleware(command)
      Cuprum::Middleware.apply(
        command:    command,
        middleware: middleware
      )
    end

    def build_responder(request)
      responder_class = responder_for(request.format)

      responder_class.new(
        action_name:   action_name,
        member_action: member_action?,
        resource:      resource,
        serializers:   merge_serializers_for(request.format)
      )
    end

    def merge_serializers_for(format)
      scoped_serializers(configuration.serializers, format: format)
        .merge(scoped_serializers(serializers, format: format))
    end

    def middleware
      configuration
        .middleware_for(action_name)
        .map(&:command)
    end

    def scoped_serializers(serializers, format:)
      serializers
        .select { |key, _| key.is_a?(Class) }
        .merge(serializers.fetch(format, {}))
    end
  end
end
