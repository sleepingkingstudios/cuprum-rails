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

      map_errors(native_errors:)
    end

    private

    # :nocov:
    def map_errors(native_errors:)
      if Rails.version < '6.1'
        map_errors_hash(native_errors:)
      else
        map_errors_object(native_errors:)
      end
    end

    def map_errors_hash(native_errors:) # rubocop:disable Metrics/MethodLength
      errors   = Stannum::Errors.new
      details  = native_errors.details
      messages = native_errors.messages

      native_errors.keys.each do |attribute| # rubocop:disable Style/HashEachMethods
        scoped = attribute == :base ? errors : errors[attribute]

        details[attribute].each.with_index do |hsh, index|
          message = messages[attribute][index]

          scoped.add(hsh[:error], **hsh.except(:error), message:)
        end
      end

      errors
    end

    def map_errors_object(native_errors:)
      errors = Stannum::Errors.new

      native_errors.each do |error|
        attribute = error.attribute
        scoped    = attribute == :base ? errors : errors[attribute]

        scoped.add(error.type, **error.options, message: error.message)
      end

      errors
    end
  end
  # :nocov:
end
