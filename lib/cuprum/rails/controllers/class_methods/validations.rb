# frozen_string_literal: true

require 'cuprum/rails/controllers/class_methods'

module Cuprum::Rails::Controllers::ClassMethods
  # @private
  module Validations
    private

    def validate_class(value, as:)
      return if value.is_a?(Class)

      raise ArgumentError, "#{as} must be a Class", caller(1..-1)
    end

    def validate_name(value, as:)
      raise ArgumentError, "#{as} can't be blank", caller(1..-1) if value.nil?

      unless value.is_a?(String) || value.is_a?(Symbol)
        raise ArgumentError,
          "#{as} must be a String or Symbol",
          caller(1..-1)
      end

      return unless value.to_s.empty?

      raise ArgumentError, "#{as} can't be blank", caller(1..-1)
    end
  end
end
