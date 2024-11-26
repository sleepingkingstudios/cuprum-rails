# frozen_string_literal: true

require 'cuprum/rails/commands/resources/new'
require 'cuprum/rails/rspec/deferred/commands/resources/create_examples'

require 'support/commands/monsters'

# @note Integration test with custom entity class and properties.
RSpec.describe Cuprum::Rails::Commands::Resources::Create do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::CreateExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:repository) { Cuprum::Collections::Basic::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(name: 'monsters', **resource_options)
  end
  let(:resource_options) do
    { permitted_attributes: %w[challenge name type] }
  end
  let(:default_contract) do
    Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
      key 'challenge',  Stannum::Constraints::Presence.new
      key 'name',       Stannum::Constraints::Presence.new
      key 'type',       Stannum::Constraints::Presence.new
    end
  end
  let(:attributes) do
    {
      'name'      => 'Dracolich',
      'challenge' => 30,
      'type'      => 'bones'
    }
  end
  let(:invalid_attributes) do
    {
      'name'      => 'Dracolich',
      'challenge' => 30
    }
  end
  let(:expected_attributes) do
    {
      'name'      => 'Dracolich',
      'challenge' => 30,
      'type'      => 'bones'
    }
  end

  include_deferred 'should implement the Create command'
end
