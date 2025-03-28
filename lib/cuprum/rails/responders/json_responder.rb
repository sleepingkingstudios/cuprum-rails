# frozen_string_literal: true

require 'cuprum/rails/responders'
require 'cuprum/rails/responders/actions'
require 'cuprum/rails/responders/base_responder'
require 'cuprum/rails/responders/matching'
require 'cuprum/rails/responders/serialization'
require 'cuprum/rails/responses/json_response'
require 'cuprum/rails/serializers/base_serializer'
require 'cuprum/rails/serializers/json'

module Cuprum::Rails::Responders
  # Provides a DSL for defining responses to JSON requests.
  #
  # By default, responds to any successful result by serializing the result
  # value and generating a JSON object of the form { 'ok' => true, 'data' =>
  # serialized_value }.
  #
  # For a failing result, it generates and serializes a generic error and
  # generates a JSON object of the form { 'ok' => false, 'data' =>
  # serialized_error }. This is to prevent leaks of internal states that might
  # help an adversary access your system. Use the .match class method to define
  # more useful responses for whitelisted errors.
  #
  # @example Defining Error Responses
  #   class CustomResponder < Cuprum::Rails::Responders::HtmlResponder
  #     match :failure, error: Spec::NotFound do |result|
  #       render_failure(result.error, status: 404)
  #     end
  #
  #     match :failure, error: Spec::AuthorizationFailure do
  #       error = Cuprum::Error.new(message: "I can't let you do that, Dave")
  #
  #       render_failure(error, status: 403)
  #     end
  #   end
  class JsonResponder < BaseResponder
    include Cuprum::Rails::Responders::Matching
    include Cuprum::Rails::Responders::Actions
    include Cuprum::Rails::Responders::Serialization

    GENERIC_ERROR = Cuprum::Error.new(
      message: 'Something went wrong when processing the request'
    ).freeze
    private_constant :GENERIC_ERROR

    match :success do |result|
      render_success(result.value)
    end

    match :failure do |result|
      render_failure(Rails.env.development? ? result.error : generic_error)
    end

    # @param action_name [String, Symbol] the name of the action to match.
    # @param controller [Cuprum::Rails::Controller] the called controller.
    # @param controller_name [String] the name of the called controller.
    #   Defaults to controller.class.name.
    # @param matcher [Cuprum::Matcher] an optional matcher specific to the
    #   action. This will be matched before any of the generic matchers.
    # @param member_action [Boolean] true if the action acts on a collection
    #   item, not on the collection as a whole.
    # @param request [Cuprum::Rails::Request] the request to the controller.
    # @param serializers [Hash<Class, Object>] the serializers for converting
    #   result values into serialized data.
    # @param options [Hash] additional parameters for the responder.
    def initialize( # rubocop:disable Metrics/ParameterLists
      action_name:,
      controller:,
      request:,
      serializers:,
      member_action: false,
      **options
    )
      super(
        action_name:,
        controller:,
        matcher:,
        member_action:,
        resource:,
        request:,
        serializers:,
        **options
      )
    end

    # @!method call(result)
    #   (see Cuprum::Rails::Responders::Actions#call)

    # @return [Symbol] the format of the responder.
    def format
      :json
    end

    # @return [Cuprum::Error] a generic error for generating failure responses.
    def generic_error
      GENERIC_ERROR
    end

    # Creates a JsonResponse based on the given data and options.
    #
    # @param json [Object] The data to serialize.
    # @param status [Integer] The HTTP status of the response.
    #
    # @return [Cuprum::Rails::Responses::JsonResponse] the response.
    def render(json, status: 200)
      Cuprum::Rails::Responses::JsonResponse.new(
        data:   serialize(json),
        status:
      )
    end

    # Creates a JsonResponse for a failed result.
    #
    # @param error [Cuprum::Error] The error from the failed result.
    # @param status [Integer] The HTTP status of the response.
    #
    # @return [Cuprum::Rails::Responses::JsonResponse] the response.
    def render_failure(error, status: 500)
      json = { 'ok' => false, 'error' => error }

      render(json, status:)
    end

    # Creates a JsonResponse for a successful result.
    #
    # @param value [Object] The value of the successful result.
    # @param status [Integer] The HTTP status of the response.
    #
    # @return [Cuprum::Rails::Responses::JsonResponse] the response.
    def render_success(value, status: 200)
      json = { 'ok' => true, 'data' => value }

      render(json, status:)
    end
  end
end
