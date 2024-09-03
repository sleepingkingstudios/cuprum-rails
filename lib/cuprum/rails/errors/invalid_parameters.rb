# frozen_string_literal: true

require 'cuprum/error'

require 'cuprum/rails/errors'

module Cuprum::Rails::Errors
  # Error class when a parameters hash does not match the expected contract.
  class InvalidParameters < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'cuprum.rails.errors.invalid_parameters'

    # @param errors [Stannum::Errors] the errors returned by the contract.
    def initialize(errors:)
      @errors = errors

      super(message: default_message, errors:)
    end

    # @return [Stannum::Errors] the errors returned by the contract.
    attr_reader :errors

    private

    def as_json_data
      error_data =
        errors
          .group_by_path
          .to_h do |path, errors|
            [
              join_path(path),
              errors.map { |error| format_error(error) }
            ]
          end

      { 'errors' => error_data }
    end

    def default_message
      "invalid request parameters - #{errors.summary}"
    end

    def format_error(error)
      tools.hash_tools.convert_keys_to_strings(error)
    end

    def join_path(path)
      path.join('.')
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
