# frozen_string_literal: true

require 'cuprum/rails/records/repository'
require 'cuprum/rails/resource'
require 'cuprum/rails/rspec/deferred/commands/resources/new_examples'

require 'support/tome'

# @note Integration test for command with custom collection.
RSpec.describe Cuprum::Rails::Commands::Resources::New do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::NewExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:repository) { Cuprum::Rails::Records::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(entity_class: Tome, **resource_options)
  end
  let(:resource_options) do
    { permitted_attributes: %w[uuid title author series category] }
  end
  let(:entity_class) { Tome }
  let(:attributes) do
    {
      'uuid'   => '00000000-0000-0000-0000-000000000000',
      'title'  => 'Gideon the Ninth',
      'author' => 'Tamsyn Muir'
    }
  end
  let(:empty_attributes) do
    {
      'uuid'         => nil,
      'title'        => '',
      'author'       => '',
      'series'       => nil,
      'category'     => nil,
      'published_at' => nil
    }
  end
  let(:expected_attributes) do
    empty_attributes.merge(
      'uuid'   => '00000000-0000-0000-0000-000000000000',
      'title'  => 'Gideon the Ninth',
      'author' => 'Tamsyn Muir'
    )
  end

  include_deferred 'should implement the New command'
end
