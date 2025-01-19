# frozen_string_literal: true

require 'cuprum/rails/commands/resources/update'
require 'cuprum/rails/rspec/deferred/commands/resources/update_examples'

require 'support/commands/monsters'

# @note Integration test with custom entity class and properties.
RSpec.describe Cuprum::Rails::Commands::Resources::Update do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::UpdateExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:repository) { Cuprum::Collections::Basic::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(name: 'monsters', **resource_options)
  end
  let(:resource_options) do
    {
      permitted_attributes: %w[challenge name type],
      primary_key_name:     'id'
    }
  end
  let(:default_contract) do
    Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
      key 'challenge',  Stannum::Constraints::Presence.new
      key 'name',       Stannum::Constraints::Presence.new
      key 'type',       Stannum::Constraints::Presence.new
    end
  end
  let(:fixtures_data) { Spec::Support::Commands::Monsters::FIXTURES }
  let(:resource_scope) do
    Cuprum::Collections::Scope.new do |query|
      { 'challenge' => query.gte(10) }
    end
  end
  let(:non_matching_scope) do
    Cuprum::Collections::Scope.new do |query|
      { 'challenge' => query.gte(30) }
    end
  end
  let(:unique_scope) do
    Cuprum::Collections::Scope.new do |query|
      {
        'challenge' => query.gte(10),
        'type'      => 'flesh'
      }
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
      'challenge' => 30,
      'type'      => nil
    }
  end
  let(:expected_attributes) do
    {
      'id'        => expected_entity['id'],
      'name'      => 'Dracolich',
      'challenge' => 30,
      'type'      => 'bones'
    }
  end

  include_deferred 'should implement the Update command'
end
