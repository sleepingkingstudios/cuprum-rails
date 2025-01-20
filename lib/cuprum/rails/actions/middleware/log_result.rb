# frozen_string_literal: true

require 'pp'

require 'cuprum/rails/actions/middleware'

module Cuprum::Rails::Actions::Middleware
  # Middleware for logging controller action results.
  class LogResult < Cuprum::Command
    include Cuprum::Middleware

    private

    def format_log(result:)
      msg = "  #{self.class.name}#process"

      logged_properties(result:).each do |label, formatted|
        msg << "\n    #{label}\n"
        msg << tools.string_tools.indent(formatted, 6)
      end

      msg
    end

    def logged_properties(result:)
      hsh = {
        status: result.status,
        value:  result.value,
        error:  result.error
      }

      hsh
        .merge(result.properties.except(:status, :value, :error))
        .to_h { |key, value| [key.to_s.titleize, value.pretty_inspect] }
    end

    def process(next_command, **options)
      result = next_command.call(**options)

      if result.success?
        Rails.logger.info format_log(result:)
      else
        Rails.logger.error format_log(result:)
      end

      result
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
