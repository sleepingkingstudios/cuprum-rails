# frozen_string_literal: true

require 'cuprum/middleware'

require 'support/middleware'

module Spec::Support::Middleware
  class SessionMiddleware < Cuprum::Command
    include Cuprum::Middleware

    private

    def process(next_command, request:)
      result = next_command.call(request: request)

      Cuprum::Rails::Result.new(
        **result.properties,
        value: result.value.merge('session' => { 'token' => '12345' })
      )
    end
  end
end
