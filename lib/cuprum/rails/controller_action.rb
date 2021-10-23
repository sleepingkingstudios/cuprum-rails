# frozen_string_literal: true

require 'forwardable'

require 'cuprum/rails'

module Cuprum::Rails
  # @api private
  #
  # Implements a controller action.
  #
  # @note This class should not be initialized directly. Instead, use the
  #   Cuprum::Rails::Controller.action class method to define an action.
  class ControllerAction
    extend Forwardable

    # @param configuration [Cuprum::Rails::Controllers::Configuration] the
    #   configuration for the originating controller.
    # @param action_class [Class] The class of the action command. Must be
    #   constructible with keyword :resource.
    # @param action_name [String, Symbol] The name of the action.
    # @param member_action [Boolean] True if the action acts on a collection
    #   item, not on the collection as a whole.
    def initialize(
      configuration,
      action_class:,
      action_name:,
      member_action: false
    )
      @configuration = configuration
      @action_class  = action_class
      @action_name   = action_name
      @member_action = !!member_action
    end

    # @return [Class] the class of the action command.
    attr_reader :action_class

    # @return [String, Symbol] the name of the action.
    attr_reader :action_name

    # @return [Cuprum::Rails::Controllers::Configuration] the configuration for
    #   the originating controller.
    attr_reader :configuration

    # @!method resource
    #   @return [Cuprum::Rails::Resource] the resource defined for the
    #     controller.

    # @!method responder_for
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
    # @param request [ActionDispatch::Request] The request to process.
    #
    # @return [#call] The response object.
    def call(request)
      responder = build_responder(request)
      action    = action_class.new(resource: resource)
      result    = action.call(request: request)

      responder.call(result)
    end

    # @return [Boolean] true if the action acts on a collection item, not on the
    #   collection as a whole.
    def member_action?
      @member_action
    end

    private

    def build_responder(request)
      format          = request.format.symbol
      responder_class = responder_for(format)

      responder_class.new(
        action_name:   action_name,
        member_action: member_action?,
        resource:      resource
      )
    end
  end
end
