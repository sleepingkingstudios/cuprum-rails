# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/command_contracts'

require 'cuprum/rails/commands/find_matching'
require 'cuprum/rails/rspec/contracts/command_contracts'

require 'support/examples/rails_command_examples'

RSpec.describe Cuprum::Rails::Commands::FindMatching do
  include Cuprum::Collections::RSpec::Contracts::CommandContracts
  include Cuprum::Rails::RSpec::Contracts::CommandContracts
  include Spec::Support::Examples::RailsCommandExamples

  include_context 'with parameters for a Rails command'

  subject(:command) do
    described_class.new(
      query:        query,
      record_class: record_class,
      **constructor_options
    )
  end

  let(:query) { Cuprum::Rails::Query.new(record_class) }
  let(:expected_data) do
    matching_data.map do |attributes|
      Book.where(attributes).first
    end
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:collection_name, :envelope, :query, :record_class)
        .and_any_keywords
    end
  end

  include_contract 'should be a rails command'

  include_contract 'should be a find matching command'
end
