# frozen_string_literal: true

require 'cuprum/rails/responders'

module Cuprum::Rails::Responders
  # Abstract base class for defining responders.
  class BaseResponder
    extend Forwardable

    # @param action_name [String, Symbol] the name of the action to match.
    # @param controller [Cuprum::Rails::Controller] the called controller.
    # @param member_action [Boolean] true if the action acts on a collection
    #   item, not on the collection as a whole.
    # @param request [Cuprum::Rails::Request] the request to the controller.
    def initialize(
      action_name:,
      controller:,
      request:,
      member_action: false,
      **_options
    )
      @action_name     = action_name
      @controller      = controller
      @controller_name = controller.class.name
      @member_action   = !!member_action # rubocop:disable Style/DoubleNegation
      @request         = request
      @resource        = controller.class.resource
    end

    # @return [String, Symbol] the name of the action to match.
    attr_reader :action_name

    # @return [Cuprum::Rails::Controller] the called controller.
    attr_reader :controller

    # @return [String] the name of the called controller.
    attr_reader :controller_name

    # @return [Cuprum::Rails::Request] the request to the controller.
    attr_reader :request

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

    # Helper for accessing the configured routes for the resource.
    #
    # Any wildcards from the path params will be applied to the routes.
    #
    # @return [Cuprum::Rails::Routes] the configured routes.
    def routes
      resource.routes.with_wildcards(routes_wildcards)
    end

    private

    def routes_wildcards
      request.path_params || {}
    end
  end
end
