# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/controller_examples'

require 'support/controllers/authors_controller'

# @note Integration spec for Deferred::ControllerExamples.
RSpec.describe AuthorsController do
  include RSpec::SleepingKingStudios::Deferred::Consumer
  include Cuprum::Rails::RSpec::Deferred::ControllerExamples

  include_deferred 'should define middleware',
    Spec::Support::Middleware::ApiVersionMiddleware,
    formats:  :json,
    matching: -> { have_attributes(api_version: '1982-07') }

  include_deferred 'should define middleware',
    Spec::Support::Middleware::ApiVersionMiddleware,
    formats:  :xml,
    matching: { api_version: '1.0.0-alpha' }

  include_deferred 'should define middleware',
    Spec::Support::Middleware::LoggingMiddleware

  include_deferred 'should define middleware',
    Spec::Support::Middleware::ProfilingMiddleware,
    actions: { only: %i[create update] }

  include_deferred 'should define middleware',
    Spec::Support::Middleware::SessionMiddleware,
    formats: :html
end
