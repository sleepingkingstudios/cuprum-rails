# frozen_string_literal: true

require 'cuprum'

require 'cuprum/rails'

module Cuprum::Rails
  # Abstract class for commands that can be wrapped with a controller action.
  class Command < Cuprum::Command
    include Cuprum::ExceptionHandling
    include Cuprum::ParameterValidation

    # @param resource [Cuprum::Rails::Resource] the controller resource, if any.
    # @param repository [Cuprum::Collections::Repository] the repository
    #   containing the data collections for the application or scope.
    # @param options [Hash<Symbol, Object>] additional options for the command.
    def initialize(repository: nil, resource: nil, **options)
      super()

      @repository = repository
      @resource   = resource
      @options    = options
    end

    # @return [Hash<Symbol, Object>] additional options for the command.
    attr_reader :options

    # @return [Cuprum::Collections::Repository] the repository containing the
    #   data collections for the application or scope.
    attr_reader :repository

    # @return [Cuprum::Rails::Resource] the controller resource, if any.
    attr_reader :resource
  end
end
