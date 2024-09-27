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
    #
    # @yield If a block is given, the block is used to define a private #process
    #   method. This overwrites any existing #process method. When the command
    #   is called, #process will be called internally and passed the parameters.
    #
    # @yieldparam keywords [Hash] the keywords passed to #call.
    #
    # @yieldreturn [Cuprum::Result, Object] the returned result or object is
    #   converted to a Cuprum::Result and returned by #call.
    def initialize(repository: nil, resource: nil, **options, &implementation)
      super(&implementation)

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
