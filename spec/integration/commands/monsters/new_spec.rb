# frozen_string_literal: true

require 'cuprum/rails/commands/resources/new'
require 'cuprum/rails/rspec/deferred/commands/resources/new_examples'

require 'support/commands/monsters'

# @note Integration test with custom entity class and properties.
RSpec.describe Cuprum::Rails::Commands::Resources::New do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::NewExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:repository) { Cuprum::Collections::Basic::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(name: 'monsters', **resource_options)
  end
  let(:resource_options) do
    { permitted_attributes: %w[challenge name type] }
  end
  let(:valid_attributes) do
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
  let(:extra_attributes) do
    {
      'resistances' => %w[necrotic poison]
    }
  end

  include_deferred 'should implement the New command'
end
