# frozen_string_literal: true

module Cuprum::Rails::RSpec
  # Helper methods for defining RSpec contracts.
  module ContractHelpers
    class << self
      # Resolves a configuration option.
      #
      # If the configured value is a Proc, the Proc is executed in the context
      # of the example group and the resulting value returned. Otherwise,
      # returns the configured value, or the given default if the configured
      # value is nil.
      #
      # @param value [Object] The configured value for the option.
      # @param context [RSpec::SleepingKingStudios::ExampleGroup] The example
      #   group used as a context if the configured value is a Proc.
      # @param default [Object] An optional default value if the configured
      #   value is nil.
      def option_with_default(value, context:, default: nil)
        # :nocov:
        case value
        when Proc
          return context.instance_exec(&value) if value.arity.zero?

          context.instance_exec(default, &value)
        when nil
          default
        else
          value
        end
        # :nocov:
      end
    end

    # Resolves a configuration option.
    #
    # If the configured value is a Proc, the Proc is executed in the context of
    # the example group and the resulting value returned. Otherwise, returns the
    # configured value, or the given default if the configured value is nil.
    #
    # @param value [Object] The configured value for the option.
    # @param context [RSpec::SleepingKingStudios::ExampleGroup] The example
    #   group used as a context if the configured value is a Proc.
    # @param default [Object] An optional default value if the configured value
    #   is nil.
    def option_with_default(value, context: nil, default: nil)
      # :nocov:
      Cuprum::Rails::RSpec::ContractHelpers
        .option_with_default(
          value,
          context: context || self,
          default:
        )
      # :nocov:
    end
  end
end
