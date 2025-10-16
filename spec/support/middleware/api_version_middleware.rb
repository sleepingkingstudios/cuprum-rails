# frozen_string_literal: true

require 'cuprum/middleware'

require 'support/middleware'

module Spec::Support::Middleware
  class ApiVersionMiddleware < Cuprum::Command
    include Cuprum::Middleware

    def initialize(api_version)
      super()

      @api_version = api_version
    end

    attr_reader :api_version

    private

    def process(next_command, **rest)
      result = next_command.call(**rest)

      Cuprum::Rails::Result.new(
        **result.properties,
        value: (result.value || {}).merge('api_version' => api_version)
      )
    end
  end
end
