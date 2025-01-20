# frozen_string_literal: true

require 'cuprum/rails/commands/resources/destroy'
require 'cuprum/rails/rspec/deferred/commands/resources/destroy_examples'

require 'support/commands/monsters'

# @note Integration test with custom entity class and properties.
RSpec.describe Cuprum::Rails::Commands::Resources::Destroy do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::DestroyExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:repository) { Cuprum::Collections::Basic::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(name: 'monsters', **resource_options)
  end
  let(:resource_options) { { primary_key_name: 'id' } }
  let(:fixtures_data)    { Spec::Support::Commands::Monsters::FIXTURES }
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

  include_deferred 'should implement the Destroy command'
end
