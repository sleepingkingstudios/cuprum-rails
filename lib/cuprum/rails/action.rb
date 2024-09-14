# frozen_string_literal: true

require 'forwardable'

require 'cuprum/command'

require 'cuprum/rails'

module Cuprum::Rails
  # Abstract command that implement a controller action.
  class Action < Cuprum::Command
    extend Forwardable

    # @!method call(request:, repository: nil, resource: nil, **options)
    #   Performs the controller action.
    #
    #   Subclasses should implement a #process method with the :request keyword,
    #   which accepts an ActionDispatch::Request instance.
    #
    #   @param request [ActionDispatch::Request] the Rails request.
    #   @param repository [Cuprum::Collections::Repository] the repository
    #     containing the data collections for the application or scope.
    #   @param resource [Cuprum::Rails::Resource] the controller resource.
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
    #
    # @deprecated 0.3.0 Calling Action.build is deprecated.
    def self.build(&implementation)
      SleepingKingStudios::Tools::Toolbelt.instance.core_tools.deprecate(
        'Cuprum::Rails::Action.build',
        message: 'Use Action.subclass instead'
      )

      Class.new(self) do
        define_method(:process, &implementation)
      end
    end

    # @overload initialize(command_class:)
    #   @todo
    #
    # @overload initialize(&implementation)
    #   @todo
    def initialize(command_class: nil, &implementation)
      if implementation && command_class
        raise ArgumentError,
          'implementation block overrides command_class parameter'
      end

      super(&implementation)

      @command_class = command_class
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

    # @return [Cuprum::Rails::Resource] the controller resource.
    attr_reader :resource

    private

    def build_command
      command_class&.new(**command_options)
    end

    def build_response(value)
      value
    end

    def build_result(error: nil, metadata: nil, status: nil, value: nil)
      Cuprum::Rails::Result.new(
        error:,
        metadata:,
        status:,
        value:
      )
    end

    def command_class
      @command_class ||= default_command_class
    end

    def command_options
      {
        repository:,
        resource:,
        **options
      }
    end

    def default_command_class
      nil
    end

    def map_parameters
      request.params
    end

    def process(request:, repository: nil, resource: nil, **options)
      @params     = nil
      @repository = repository
      @request    = request
      @resource   = resource
      @options    = options

      step { process_command } if command_class
    end

    def process_command
      params  = step { map_parameters }
      command = step { build_command }
      value   = step { command.call(**params) }

      build_response(value)
    end
  end
end
