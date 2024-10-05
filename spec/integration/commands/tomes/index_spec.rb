# frozen_string_literal: true

require 'cuprum/rails/records/repository'
require 'cuprum/rails/resource'
require 'cuprum/rails/rspec/deferred/commands/resources/index_examples'

require 'support/tome'

# @note Integration test for command with custom collection.
RSpec.describe Cuprum::Rails::Commands::Resources::Index do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::IndexExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:repository) { Cuprum::Rails::Records::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(entity_class: Tome, **resource_options)
  end
  let(:resource_options) { { default_order: 'uuid' } }
  let(:fixtures_data) do
    Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.map do |attributes|
      attributes = attributes.except('id').merge('uuid' => SecureRandom.uuid)

      Tome.new(**attributes)
    end
  end
  let(:ordered_data) { filtered_data.sort_by(&:uuid) }

  include_deferred 'should implement the Index command'
end
