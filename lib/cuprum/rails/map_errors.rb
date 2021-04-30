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

    # @todo Document #call.
    def call(native_errors:)
      unless native_errors.is_a?(ActiveModel::Errors)
        raise ArgumentError,
          'native_errors must be an instance of ActiveModel::Errors'
      end

      map_errors(native_errors: native_errors)
    end

    private

    def map_errors(native_errors:)
      native_errors.details.each.with_object(Stannum::Errors.new) \
      do |(attribute, attribute_errors), errors|
        attribute_errors.each do |attribute_error|
          error   = attribute_error[:error]
          details = attribute_error.except(:error)
          message = native_errors.generate_message(attribute, error, details)

          (attribute == :base ? errors : errors[attribute])
            .add(error, message: message, **details)
        end
      end
    end
  end
end
