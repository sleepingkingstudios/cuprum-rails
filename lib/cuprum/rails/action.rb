# frozen_string_literal: true

require 'cuprum/command'

require 'cuprum/rails'

module Cuprum::Rails
  # Abstract command that implement a controller action.
  class Action < Cuprum::Command
    # @param options [Hash<Symbol, Object>] Additional options for the action.
    # @param repository [Cuprum::Collections::Repository] The repository
    #   containing the data collections for the application or scope.
    # @param resource [Cuprum::Rails::Resource] The controller resource.
    def initialize(resource:, repository: nil, **options)
      super()

      @repository = repository
      @resource   = resource
      @options    = options
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

    # @return [Hash<Symbol, Object>] additional options for the action.
    attr_reader :options

    # @return [Cuprum::Collections::Repository] the repository containing the
    #   data collections for the application or scope.
    attr_reader :repository

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
