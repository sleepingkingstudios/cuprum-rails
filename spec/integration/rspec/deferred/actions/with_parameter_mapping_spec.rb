# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/actions_examples'

RSpec.describe Cuprum::Rails::RSpec::Deferred::ActionsExamples do
  let(:fixture_file) do
    namespace = 'spec/integration/rspec/deferred/actions'

    "#{namespace}/with_parameter_mapping_spec.fixture.rb"
  end
  let(:result) do
    RSpec::SleepingKingStudios::Sandbox.run(fixture_file)
  end
  let(:expected_examples) do
    <<~EXAMPLES.lines.map(&:strip)
      Cuprum::Rails::Action.new is expected to construct with 0 arguments
      Cuprum::Rails::Action#call should define the method
      Cuprum::Rails::Action#command_class is expected to equal Spec::ExampleCommand
      Cuprum::Rails::Action#call should return a passing result with the response value
      Cuprum::Rails::Action#call should initialize the command
      Cuprum::Rails::Action#call should call the command
    EXAMPLES
  end

  it 'should apply the deferred examples', :aggregate_failures do
    expect(result.summary).to be == '6 examples, 0 failures'

    expect(result.example_descriptions).to be == expected_examples
  end
end
