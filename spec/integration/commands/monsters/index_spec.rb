# frozen_string_literal: true

require 'cuprum/rails/commands/resources/index'
require 'cuprum/rails/rspec/deferred/commands/resources/index_examples'

require 'support/commands/monsters'

# @note Integration test with custom entity class and properties.
RSpec.describe Cuprum::Rails::Commands::Resources::Index do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::IndexExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:repository) { Cuprum::Collections::Basic::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(name: 'monsters', **resource_options)
  end
  let(:resource_options) { { default_order: 'challenge' } }
  let(:fixtures_data)    { Spec::Support::Commands::Monsters::FIXTURES }
  let(:resource_scope) do
    Cuprum::Collections::Scope.new do |query|
      { 'challenge' => query.gte(10) }
    end
  end
  let(:ordered_data) do
    filtered_data.sort_by { |entity| entity['challenge'] }
  end
  let(:order)      { { 'name' => 'asc' } }
  let(:where_hash) { { 'type' => 'bones' } }

  def filter_data_hash(entities)
    entities.select { |entity| entity['type'] == 'bones' }
  end

  def sort_data(entities)
    entities.sort_by { |entity| entity['name'] }
  end

  include_deferred 'should implement the Index command'
end
