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

    # @overload validate_parameters(contract)
    #   Sets the contract to automatically validate the request parameters.
    #
    #   @param contract [Stannum::Contract] the contract used to validate the
    #     request parameters.
    #
    # @overload validate_parameters(&block)
    #   Defines a contract to automatically validate the request parameters.
    #
    #   @yield Used to create an indifferent hash contract to validate the
    #     request parameters.
    def self.validate_parameters(contract = nil, &)
      contract ||= Cuprum::Rails::Constraints::ParametersContract.new(&)

      define_method(:parameters_contract) { contract }
    end

    # @overload initialize(command_class:, parameters_contract: nil)
    #   @todo
    #
    # @overload initialize(parameters_contract: nil, &implementation)
    #   @todo
    def initialize(
      command_class:       nil,
      parameters_contract: nil,
      &implementation
    )
      if implementation && command_class
        raise ArgumentError,
          'implementation block overrides command_class parameter'
      end

      super(&implementation)

      @command_class       = command_class
      @parameters_contract = parameters_contract
    end

    # @!method params
    #   @return [Hash<String, Object>] the request parameters.
    def_delegators :@request, :params

    # @return [Hash<Symbol, Object>] additional options for the action.
    attr_reader :options

    # @return [Stannum::Constraints::Base, nil] constraint validating the
    #   request parameters.
    attr_reader :parameters_contract

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

      step { validate_parameters(parameters_contract) } if parameters_contract

      command_class ? process_command : super
    end

    def process_command
      params  = step { map_parameters }
      command = step { build_command }
      value   = step { command.call(**params) }

      build_response(value)
    end

    def validate_parameters(contract)
      match, errors = contract.match(params)

      return success(nil) if match

      error = Cuprum::Rails::Errors::InvalidParameters.new(errors:)
      failure(error)
    end
  end
end
