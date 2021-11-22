# frozen_string_literal: true

require 'cuprum/middleware'

require 'support/middleware'

module Spec::Support::Middleware
  class ProfilingMiddleware < Cuprum::Command
    include Cuprum::Middleware

    private

    def process(next_command, request:)
      start_time = Time.current

      value = super(next_command, request: request)

      return if value.nil?

      end_time = Time.current

      value.merge('time_elapsed' => time_elapsed(start_time, end_time))
    end

    def time_elapsed(start_time, end_time)
      difference = ((end_time - start_time).round(3) * 1_000).to_i

      "#{difference} milliseconds"
    end
  end
end
