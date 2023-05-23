# frozen_string_literal: true

require 'cuprum/rails/responders'

module Cuprum::Rails::Responders
  # Abstract base class for defining responders.
  class BaseResponder
    # @param action_name [String, Symbol] The name of the action to match.
    # @param member_action [Boolean] True if the action acts on a collection
    #   item, not on the collection as a whole.
    # @param resource [Cuprum::Rails::Resource] The resource for the controller.
    def initialize(
      action_name:,
      resource:,
      member_action: false,
      **_options
    )
      @action_name   = action_name
      @member_action = !!member_action # rubocop:disable Style/DoubleNegation
      @resource      = resource
    end

    # @return [String, Symbol] the name of the action to match.
    attr_reader :action_name

    # @return [Cuprum::Rails::Resource] the resource for the controller.
    attr_reader :resource

    # @return [Cuprum::Result] the result of calling the action.
    attr_reader :result

    # Generates the response object for the result.
    #
    # @param result [Cuprum::Result] the result of the action call.
    #
    # @return [#call] the response object from the matching response clause.
    def call(result)
      @result = result
    end

    # @return [true, false] true if the action is a member action, otherwise
    #   false.
    def member_action?
      @member_action
    end
  end
end
