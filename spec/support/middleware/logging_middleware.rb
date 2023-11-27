# frozen_string_literal: true

require 'stringio'

require 'cuprum/middleware'

require 'support/middleware'

module Spec::Support::Middleware
  class LoggingMiddleware < Cuprum::Command
    include Cuprum::Middleware

    def self.clear_logs
      @logs = StringIO.new
    end

    def self.logs
      @logs ||= StringIO.new
    end

    private

    attr_reader :repository

    attr_reader :resource

    def log(level, message)
      self.class.logs.puts("[#{level.upcase}] #{message}")
    end

    def log_details
      <<~MESSAGE
        - repository_keys: #{repository.keys.join(', ')}
        - resource_name: #{resource.name}
      MESSAGE
    end

    def log_failure(error:, request:)
      message =
        "Action failure: #{request.controller_name}##{request.action_name}"
      message += " (#{error.message})"
      message += "\n#{log_details}"

      log('error', message)
    end

    def log_request(request:, result:)
      if result.success?
        log_success(request: request)
      else
        log_failure(request: request, error: result.error)
      end
    end

    def log_success(request:)
      message =
        "Action success: #{request.controller_name}##{request.action_name}"
      message += "\n#{log_details}"

      log('info', message)
    end

    def process(next_command, request:, repository: nil, resource: nil, **rest)
      @repository = repository
      @resource   = resource

      result = next_command.call(
        request:    request,
        resource:   resource,
        repository: repository,
        **rest
      )

      log_request(request: request, result: result)

      result
    end
  end
end
