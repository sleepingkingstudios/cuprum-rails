# frozen_string_literal: true

require 'cuprum/rails/records/repository'
require 'cuprum/rails/resource'
require 'cuprum/rails/rspec/deferred/commands/resources/show_examples'

require 'support/commands/chapters/show'

# @note Integration test for command with custom logic.
RSpec.describe Spec::Support::Commands::Chapters::Show do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::ShowExamples

  subject(:command) { described_class.new(repository:, resource:) }

  deferred_context 'when the collection has many items' do
    let(:books_collection) do
      repository.find_or_create(qualified_name: 'books')
    end
    let(:chapters_collection) do
      repository.find_or_create(qualified_name: 'chapters')
    end
    let(:authors_data)  { Spec::Support::Commands::Chapters::AUTHORS_FIXTURES }
    let(:books_data)    { Spec::Support::Commands::Chapters::BOOKS_FIXTURES }
    let(:chapters_data) { Spec::Support::Commands::Chapters::CHAPTERS_FIXTURES }

    before(:example) do
      books_data.each do |entity|
        books_collection.insert_one.call(entity:)
      end

      collection_data.each do |entity|
        chapters_collection.insert_one.call(entity:)
      end
    end
  end

  let(:repository) { Cuprum::Collections::Basic::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(name: 'chapters', **resource_options)
  end
  let(:resource_options) { { primary_key_name: 'id' } }

  describe '#call' do
    let(:authors_data)    { [] }
    let(:chapters_data)   { [] }
    let(:fixtures_data)   { chapters_data }
    let(:collection_data) { fixtures_data }
    let(:resource_scope)  { Cuprum::Collections::Scope.new({ 'book_id' => 0 }) }
    let(:unique_scope)    { Cuprum::Collections::Scope.new({ 'book_id' => 1 }) }
    let(:non_matching_scope) do
      Cuprum::Collections::Scope.new({ 'book_id' => 2 })
    end
    let(:author) do
      authors_data.find { |author| author['id'] == expected_book['author_id'] }
    end
    let(:expected_book) do
      books_data.find { |book| book['id'] == expected_chapter['book_id'] }
    end
    let(:expected_chapter) do
      chapters_data.first
    end
    let(:expected_entity) do
      expected_chapter.merge(
        'author' => author,
        'book'   => expected_book
      )
    end
    let(:expected_unique_entity) do
      chapters_data
        .find { |chapter| chapter['book_id'] == 1 }
        .merge(
          'author' => authors_data.find { |author| author['id'] == 0 },
          'book'   => books_data.find { |book| book['id'] == 1 }
        )
    end

    def call_command
      command.call(author:, entity:, primary_key:)
    end

    include_deferred 'should require entity'

    include_deferred 'with a valid entity' do
      include_deferred 'should find the entity'
    end
  end
end
