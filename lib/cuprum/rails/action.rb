# frozen_string_literal: true

require 'forwardable'

require 'cuprum/command'

require 'cuprum/rails'

module Cuprum::Rails
  # Abstract command that implement a controller action.
  class Action < Cuprum::Command
    extend Forwardable

    # @!method call(request:, repository: nil, **options)
    #   Performs the controller action.
    #
    #   Subclasses should implement a #process method with the :request keyword,
    #   which accepts an ActionDispatch::Request instance.
    #
    #   @param request [ActionDispatch::Request] the Rails request.
    #   @param repository [Cuprum::Collections::Repository] the repository
    #     containing the data collections for the application or scope.
    #   @param options [Hash<Symbol, Object>] additional options for the action.
    #
    #   @return [Cuprum::Result] the result of the action.

    # Creates a new action class with the given implementation.
    #
    # @yield the action implementation.
    # @yieldparam request [ActionDispatch::Request] the Rails request.
    # @yieldparam repository [Cuprum::Collections::Repository] the repository
    #   containing the data collections for the application or scope.
    # @yieldparam resource [Cuprum::Collections::Resource] the resource for the
    #   controller.
    # @yieldparam options [Hash<Symbol, Object>] additional options for the
    #   action.
    # @yieldreturn [Cuprum::Result] the result of the action.
    def self.build(&implementation)
      Class.new(self) do
        define_method(:initialize) { super(&implementation) }
      end
    end

    # @!method params
    #   @return [Hash<String, Object>] the request parameters.
    def_delegators :@request, :params

    # @return [Hash<Symbol, Object>] additional options for the action.
    attr_reader :options

    # @return [Cuprum::Collections::Repository] the repository containing the
    #   data collections for the application or scope.
    attr_reader :repository

    # @return [Cuprum::Rails::Request] the formatted request.
    attr_reader :request

    private

    def build_result(error: nil, metadata: nil, status: nil, value: nil)
      Cuprum::Rails::Result.new(
        error:    error,
        metadata: metadata,
        status:   status,
        value:    value
      )
    end

    def process(request:, repository: nil, **options)
      @params     = nil
      @repository = repository
      @request    = request
      @options    = options

      nil
    end
  end
end
