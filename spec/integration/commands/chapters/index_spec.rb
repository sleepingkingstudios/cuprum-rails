# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/commands/resources/index_examples'

require 'support/commands/chapters/index'

# @note Integration test for command with custom logic.
RSpec.describe Spec::Support::Commands::Chapters::Index do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::IndexExamples

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

      chapters_data.each do |entity|
        chapters_collection.insert_one.call(entity:)
      end
    end
  end

  let(:repository) { Cuprum::Collections::Basic::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(name: 'chapters', **resource_options)
  end
  let(:resource_options) { { default_order: 'id' } }

  describe '#call' do
    let(:authors_data)    { [] }
    let(:collection_data) { [] }

    def call_command
      command.call(authors: authors_data)
    end

    include_deferred 'should find the matching collection data'

    wrap_deferred 'when the collection has many items' do
      let(:expected_data) do
        chapters_data.map do |chapter|
          book    = books_data.find { |item| item['id'] == chapter['book_id'] }
          author  =
            authors_data.find { |item| item['id'] == book['author_id'] }
          chapter = chapter.merge(
            'author' => author,
            'book'   => book
          )
        end
      end

      include_deferred 'should find the matching collection data'
    end
  end
end
