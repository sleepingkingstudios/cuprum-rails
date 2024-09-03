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

    # @param action_class [Class] the class of the action command. Must be
    #   constructible with keyword :resource.
    # @param action_name [String, Symbol] the name of the action.
    # @param member_action [Boolean] true if the action acts on a collection
    #   item, not on the collection as a whole.
    def initialize(
      action_class:,
      action_name:,
      member_action: false
    )
      @action_class    = action_class
      @action_name     = action_name
      @member_action   = !!member_action
    end

    # @return [Class] the class of the action command.
    attr_reader :action_class

    # @return [String, Symbol] the name of the action.
    attr_reader :action_name

    # Executes the controller action.
    #
    # 1. Initializes the action command with the resource.
    # 2. Calls the command with the request.
    # 3. Builds the responder with the resource and action metadata.
    # 4. Calls the responder with the action result.
    #
    # @param controller [Cuprum::Rails::Controller] the controller instance
    #   calling the request.
    # @param request [Cuprum::Rails::Request] the request to process.
    #
    # @return [#call] the response object.
    def call(controller, request)
      responder  = build_responder(controller, request)
      action     = apply_middleware(controller, action_class.new)
      result     = action.call(request:, **controller.action_options)

      responder.call(result)
    end

    # @return [Boolean] true if the action acts on a collection item, not on the
    #   collection as a whole.
    def member_action?
      @member_action
    end

    private

    def apply_middleware(controller, command)
      configuration = controller.class.configuration
      middleware    =
        configuration
          .middleware_for(action_name)
          .map { |config| build_middleware(config.command) }

      Cuprum::Middleware.apply(
        command:,
        middleware:
      )
    end

    def build_middleware(command)
      return command unless command.is_a?(Class)

      command.new
    end

    def build_responder(controller, request)
      configuration   = controller.class.configuration
      responder_class = configuration.responder_for(request.format)

      responder_class.new(
        action_name:,
        controller:,
        member_action: member_action?,
        request:,
        serializers:   configuration.serializers_for(request.format)
      )
    end
  end
end
