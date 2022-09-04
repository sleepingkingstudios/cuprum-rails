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

      super(message: default_message, errors: errors)
    end

    # @return [Stannum::Errors] the errors returned by the contract.
    attr_reader :errors

    private

    def as_json_data
      { 'errors' => errors.group_by_path }
    end

    def default_message
      "invalid request parameters - #{errors.summary}"
    end
  end
end
