# frozen_string_literal: true

require 'cuprum/rails/records/repository'
require 'cuprum/rails/resource'
require 'cuprum/rails/rspec/deferred/commands/resources/update_examples'

require 'support/examples/commands/books_examples'
require 'support/tome'

# @note Integration test for command with custom collection.
RSpec.describe Cuprum::Rails::Commands::Resources::Update do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::UpdateExamples
  include Spec::Support::Examples::Commands::BooksExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:repository) { Cuprum::Rails::Records::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(entity_class: Tome, **resource_options)
  end
  let(:resource_options) do
    {
      permitted_attributes: %w[uuid title author series category],
      primary_key_name:     'uuid'
    }
  end
  let(:fixtures_data) do
    Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.map do |attributes|
      attributes = attributes.except('id').merge('uuid' => SecureRandom.uuid)

      Tome.new(**attributes)
    end
  end
  let(:invalid_primary_key_value) do
    SecureRandom.uuid
  end
  let(:valid_attributes) do
    {
      'title'  => 'Gideon the Ninth',
      'author' => 'Tamsyn Muir'
    }
  end
  let(:invalid_attributes) do
    {
      'title'  => 'Gideon the Ninth',
      'author' => nil
    }
  end
  let(:extra_attributes) do
    {
      'published_at' => '2019-09-10'
    }
  end

  include_deferred 'with parameters for a Book command'

  include_deferred 'should implement the Update command',
    default_contract: true
end
