# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/controller_examples'

RSpec.describe Cuprum::Rails::RSpec::Deferred::ControllerExamples do
  let(:fixture_file) do
    namespace = 'spec/integration/rspec/deferred/controllers/middleware'

    "#{namespace}/empty_middleware_spec.fixture.rb"
  end
  let(:result) do
    RSpec::SleepingKingStudios::Sandbox.run(fixture_file)
  end
  let(:expected_examples) do
    <<~EXAMPLES.lines.map(&:strip)
      BaseController.middleware should define middleware Spec::Support::Middleware::UnusedMiddleware
    EXAMPLES
  end
  let(:failure_message) do
    <<~TEXT.strip
      expected BaseController to define middleware Spec::Support::Middleware::UnusedMiddleware, but the controller does not define middleware
    TEXT
  end

  it 'should apply the deferred examples' do # rubocop:disable RSpec/MultipleExpectations
    expect(result.summary).to be == '1 example, 1 failure'

    expect(result.example_descriptions).to be == expected_examples

    expect(result.json.dig('examples', 0, 'exception', 'message'))
      .to be == failure_message
  end
end
