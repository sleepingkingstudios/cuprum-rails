# frozen_string_literal: true

require 'cuprum/command'

require 'cuprum/rails'

module Cuprum::Rails
  # Abstract command that implement a controller action.
  class Action < Cuprum::Command
    # @param resource [Cuprum::Rails::Resource] The controller resource.
    def initialize(resource:)
      super()

      @resource = resource
    end

    # @!method call(request:)
    #   Performs the controller action.
    #
    #   Subclasses should implement a #process method with the :request keyword,
    #   which accepts an ActionDispatch::Request instance.
    #
    #   @param request [ActionDispatch::Request] The Rails request.
    #
    #   @return [Cuprum::Result] the result of the action.

    # @return [Cuprum::Rails::Resource] the controller resource.
    attr_reader :resource

    private

    attr_reader :request

    def params
      @params ||= ActionController::Parameters.new(request.params)
    end

    def process(request:)
      @params  = nil
      @request = request

      nil
    end
  end
end
