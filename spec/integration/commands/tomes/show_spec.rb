# frozen_string_literal: true

require 'cuprum/rails/records/repository'
require 'cuprum/rails/resource'
require 'cuprum/rails/rspec/deferred/commands/resources/show_examples'

require 'support/tome'

# @note Integration test for command with custom collection.
RSpec.describe Cuprum::Rails::Commands::Resources::Show do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::ShowExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:repository) { Cuprum::Rails::Records::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(entity_class: Tome, **resource_options)
  end
  let(:resource_options) { {} }
  let(:fixtures_data) do
    Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.map do |attributes|
      attributes = attributes.except('id').merge('uuid' => SecureRandom.uuid)

      Tome.new(**attributes)
    end
  end
  let(:invalid_primary_key_value) do
    SecureRandom.uuid
  end

  include_deferred 'should implement the Show command'
end
