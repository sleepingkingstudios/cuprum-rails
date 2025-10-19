# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/controller_examples'

RSpec.describe Cuprum::Rails::RSpec::Deferred::ControllerExamples do
  let(:fixture_file) do
    namespace = 'spec/integration/rspec/deferred/controllers/middleware'

    "#{namespace}/invalid_matcher_spec.fixture.rb"
  end
  let(:result) do
    RSpec::SleepingKingStudios::Sandbox.run(fixture_file)
  end
  let(:expected_examples) do
    <<~EXAMPLES.lines.map(&:strip)
      AuthorsController.middleware should define middleware Spec::Support::Middleware::LoggingMiddleware
    EXAMPLES
  end
  let(:failure_message) do
    <<~TEXT.strip
      expected AuthorsController to define middleware Spec::Support::Middleware::LoggingMiddleware, but no middleware matches the class and options:

        Properties do not match:

          expected Spec::Support::Middleware::LoggingMiddleware to respond to :log_level
    TEXT
  end

  define_method :trim_whitespace do |string|
    string.each_line.map(&:rstrip).join("\n")
  end

  it 'should apply the deferred examples' do # rubocop:disable RSpec/MultipleExpectations,RSpec/ExampleLength
    expect(result.summary).to be == '1 example, 1 failure'

    expect(result.example_descriptions).to be == expected_examples

    expect(
      trim_whitespace(result.json.dig('examples', 0, 'exception', 'message'))
    )
      .to be == failure_message
  end
end
