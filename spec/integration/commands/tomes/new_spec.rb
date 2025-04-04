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
  let(:extra_attributes) do
    {
      'published_at' => '2019-09-10'
    }
  end
  let(:invalid_attributes) do
    {
      'title'  => 'Gideon the Ninth',
      'author' => nil
    }
  end
  let(:valid_attributes) do
    {
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

  include_deferred 'should implement the New command'
end
