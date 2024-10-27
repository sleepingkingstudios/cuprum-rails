# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/commands/resources/create_examples'

require 'support/book'
require 'support/commands/chapters/create'

# @note Integration test for command with custom logic.
RSpec.describe Spec::Support::Commands::Chapters::Create do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::CreateExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:repository) { Cuprum::Collections::Basic::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(name: 'chapters', **resource_options)
  end
  let(:resource_options) { { permitted_attributes: %w[title chapter_index] } }
  let(:default_contract) do
    Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
      key 'chapter_index',  Stannum::Constraints::Presence.new
      key 'title',          Stannum::Constraints::Presence.new
    end
  end
  let(:attributes) do
    {
      'title'         => 'Introduction',
      'chapter_index' => 0
    }
  end
  let(:empty_attributes)   { { 'book' => nil, 'book_id' => nil } }
  let(:invalid_attributes) { { 'title' => nil, 'chapter_index' => 0 } }
  let(:extra_attributes)   { { 'book_id' => 10 } }
  let(:expected_attributes) do
    empty_attributes.merge(
      'title'         => 'Introduction',
      'chapter_index' => 0
    )
  end

  include_deferred 'should implement the Create command'

  describe '#call' do
    describe 'with book: value' do
      let(:book) { Spec::Support::Commands::Chapters::BOOKS_FIXTURES.first }
      let(:expected_attributes) do
        super().merge(
          'book'    => book,
          'book_id' => book['id']
        )
      end

      def call_command
        command.call(attributes:, book:)
      end

      before(:example) do
        repository.create(
          default_contract:,
          qualified_name:   resource.qualified_name
        )
      end

      include_deferred 'should create the entity'
    end
  end
end
