# frozen_string_literal: true

require 'stannum/errors'

require 'cuprum/rails'

module Cuprum::Rails
  # Maps errors from a validated Rails model to a Stannum::Errors object.
  class MapErrors
    # @return [MapErrors] a memoized instance of the class.
    def self.instance
      @instance ||= new
    end

    # Maps an ActiveModel::Errors object to a Stannum::Errors object.
    #
    # @param native_errors [ActiveModel::Errors] The Rails error object.
    #
    # @return [Stannum::Errors] the generated errors object.
    def call(native_errors:)
      unless native_errors.is_a?(ActiveModel::Errors)
        raise ArgumentError,
          'native_errors must be an instance of ActiveModel::Errors'
      end

      map_errors(native_errors: native_errors)
    end

    private

    def map_errors(native_errors:)
      errors = Stannum::Errors.new

      native_errors.each do |error|
        attribute = error.attribute
        scoped    = attribute == :base ? errors : errors[attribute]

        scoped.add(error.type, message: error.message, **error.options)
      end

      errors
    end
  end
end
