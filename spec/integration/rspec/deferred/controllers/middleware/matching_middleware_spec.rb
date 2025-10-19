# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/controller_examples'

RSpec.describe Cuprum::Rails::RSpec::Deferred::ControllerExamples do
  let(:fixture_file) do
    namespace = 'spec/integration/rspec/deferred/controllers/middleware'

    "#{namespace}/matching_middleware_spec.fixture.rb"
  end
  let(:result) do
    RSpec::SleepingKingStudios::Sandbox.run(fixture_file)
  end
  let(:expected_examples) do
    <<~EXAMPLES.lines.map(&:strip)
      AuthorsController.middleware should define middleware Spec::Support::Middleware::ApiVersionMiddleware
      AuthorsController.middleware should define middleware Spec::Support::Middleware::ApiVersionMiddleware
      AuthorsController.middleware should define middleware Spec::Support::Middleware::LoggingMiddleware
      AuthorsController.middleware should define middleware Spec::Support::Middleware::ProfilingMiddleware
      AuthorsController.middleware should define middleware Spec::Support::Middleware::SessionMiddleware
    EXAMPLES
  end

  it 'should apply the deferred examples', :aggregate_failures do
    expect(result.summary).to be == '5 examples, 0 failures'

    expect(result.example_descriptions).to be == expected_examples
  end
end
