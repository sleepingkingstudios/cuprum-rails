# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/controller_examples'

require 'support/controllers/authors_controller'
require 'support/middleware/unused_middleware'

# @note Integration spec for Deferred::ControllerExamples.
RSpec.describe AuthorsController do
  include RSpec::SleepingKingStudios::Deferred::Consumer
  include Cuprum::Rails::RSpec::Deferred::ControllerExamples

  include_deferred 'should define middleware',
    Spec::Support::Middleware::UnusedMiddleware
end
