# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/commands/find_matching_examples'

require 'cuprum/rails/records/commands/find_matching'

require 'support/examples/records/command_examples'

RSpec.describe Cuprum::Rails::Records::Commands::FindMatching do
  include Cuprum::Collections::RSpec::Deferred::Commands::FindMatchingExamples
  include Spec::Support::Examples::Records::CommandExamples

  subject(:command) { described_class.new(collection:) }

  let(:expected_data) do
    matching_data.map do |attributes|
      Book.where(attributes).first
    end
  end

  include_deferred 'with parameters for a records command'

  include_deferred 'should implement the Records::Command methods'

  include_deferred 'should implement the FindMatching command'
end
