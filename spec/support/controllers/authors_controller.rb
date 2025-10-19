# frozen_string_literal: true

require 'cuprum/rails'

require 'support/controllers/base_controller'
require 'support/middleware/api_version_middleware'
require 'support/middleware/logging_middleware'
require 'support/middleware/profiling_middleware'
require 'support/middleware/session_middleware'

class AuthorsController < BaseController
  middleware Spec::Support::Middleware::ApiVersionMiddleware.new('1982-07'),
    formats: :json

  middleware Spec::Support::Middleware::ApiVersionMiddleware.new('1.0.0-alpha'),
    formats: :xml

  middleware Spec::Support::Middleware::LoggingMiddleware

  middleware Spec::Support::Middleware::ProfilingMiddleware,
    actions: { only: %i[create update] }

  middleware Spec::Support::Middleware::SessionMiddleware,
    formats: :html
end
