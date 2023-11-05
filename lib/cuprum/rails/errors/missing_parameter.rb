# frozen_string_literal: true

require 'cuprum/rails/errors'

module Cuprum::Rails::Errors
  # Error class when a parameters hash does not include the expected keys.
  class MissingParameter < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'cuprum.rails.errors.missing_parameter'

    # @param parameter_name [String, Symbol] the name of the missing parameter.
    # @param parameters [Hash] the received parameters.
    def initialize(parameter_name:, parameters:)
      @parameter_name = parameter_name
      @parameters     = parameters

      super(
        message:        default_message,
        parameter_name: parameter_name
      )
    end

    # @return [String, Symbol] the name of the missing parameter.
    attr_reader :parameter_name

    # @return [Hash] the received parameters.
    attr_reader :parameters

    private

    def as_json_data
      {
        'parameter_name' => parameter_name,
        'parameters'     => parameters
      }
    end

    def default_message
      "missing parameter #{parameter_name.inspect}"
    end
  end
end
