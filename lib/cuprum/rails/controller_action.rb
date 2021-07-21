# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # @api private
  #
  # Implements a controller action.
  #
  # @note This class should not be initialized directly. Instead, use the
  #   Cuprum::Rails::Controller.action class method to define an action.
  class ControllerAction
    # @param action_class [Class] The class of the action command. Must be
    #   constructible with keyword :resource.
    # @param action_name [String, Symbol] The name of the action.
    # @param member_action [Boolean] True if the action acts on a collection
    #   item, not on the collection as a whole.
    def initialize(action_class:, action_name:, member_action: false)
      @action_class  = action_class
      @action_name   = action_name
      @member_action = !!member_action
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
    # @param request [ActionDispatch::Request] The request to process.
    # @param resource [Cuprum::Rails::Resource] The controller resource.
    # @param responder_class [Class] The class of the responder to initialize.
    #
    # @return [#call] The response object.
    def call(request:, resource:, responder_class:)
      action    = action_class.new(resource: resource)
      result    = action.call(request: request)
      responder = build_responder(responder_class, resource: resource)

      responder.call(result)
    end

    # @return [Boolean] true if the action acts on a collection item, not on the
    #   collection as a whole.
    def member_action?
      @member_action
    end

    private

    def build_responder(responder_class, resource:)
      responder_class.new(
        action_name:   action_name,
        member_action: member_action?,
        resource:      resource
      )
    end
  end
end
