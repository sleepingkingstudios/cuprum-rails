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
      # @param configured [Object] The configured value for the option.
      # @param context [RSpec::SleepingKingStudios::ExampleGroup] The example
      #   group used as a context if the configured value is a Proc.
      # @param default [Object] An optional default value if the configured
      #   value is nil.
      def option_with_default(configured:, context:, default: nil)
        # :nocov:
        case configured
        when Proc
          return context.instance_exec(&configured) if configured.arity.zero?

          context.instance_exec(default, &configured)
        when nil
          default
        else
          configured
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
    # @param configured [Object] The configured value for the option.
    # @param context [RSpec::SleepingKingStudios::ExampleGroup] The example
    #   group used as a context if the configured value is a Proc.
    # @param default [Object] An optional default value if the configured value
    #   is nil.
    def option_with_default(configured:, context: nil, default: nil)
      # :nocov:
      Cuprum::Rails::RSpec::ContractHelpers
        .option_with_default(
          configured: configured,
          context:    context || self,
          default:    default
        )
    end
  end
end
