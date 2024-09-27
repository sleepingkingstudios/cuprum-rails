# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/commands/resources/index_examples'

require 'support/commands/books/index_standalone_books'

# @note Integration test for command with custom logic.
RSpec.describe Spec::Support::Commands::Books::IndexStandaloneBooks do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::IndexExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:repository) { Cuprum::Collections::Basic::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(
      default_order: 'id',
      name:          'books'
    )
  end
  let(:filtered_data) do
    collection_data.select { |entity| entity['series'].nil? }
  end
  let(:ordered_data) do
    filtered_data.sort_by { |entity| entity['published_at'] }
  end

  include_deferred 'should implement the Index command'
end
