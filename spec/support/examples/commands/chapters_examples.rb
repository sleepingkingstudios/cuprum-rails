# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'cuprum/rails/records/repository'
require 'cuprum/rails/resource'

require 'support/book'
require 'support/examples/commands'

module Spec::Support::Examples::Commands
  module ChaptersExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_context 'when the collection has many items' do
      let(:books_collection) do
        repository.find_or_create(qualified_name: 'books')
      end
      let(:chapters_collection) do
        repository.find_or_create(qualified_name: 'chapters')
      end
      let(:collection) do
        chapters_collection
      end
      let(:authors_data) do
        Spec::Support::Commands::Chapters::AUTHORS_FIXTURES
      end
      let(:books_data) do
        Spec::Support::Commands::Chapters::BOOKS_FIXTURES
      end
      let(:chapters_data) do
        Spec::Support::Commands::Chapters::CHAPTERS_FIXTURES
      end
      let(:fixtures_data)   { chapters_data }
      let(:collection_data) { fixtures_data }

      before(:example) do
        books_data.each do |entity|
          books_collection.insert_one.call(entity:)
        end

        collection_data.each do |entity|
          chapters_collection.insert_one.call(entity:)
        end
      end
    end

    deferred_context 'with parameters for a Chapter command' do
      let(:repository) { Cuprum::Collections::Basic::Repository.new }
      let(:resource) do
        Cuprum::Rails::Resource.new(name: 'chapters', **resource_options)
      end
      let(:resource_options) do
        {
          default_order:        'id',
          permitted_attributes: %w[title chapter_index],
          primary_key_name:     'id'
        }
      end
      let(:authors_data)    { [] }
      let(:chapters_data)   { [] }
      let(:collection_data) { [] }
      let(:command_options) { {} }
    end

    deferred_context 'with query parameters for a Chapter command' do
      let(:primary_key) { nil }
      let(:author)      { nil }
      let(:order)       { { 'title' => 'asc' } }
      let(:where_hash)  { { 'chapter_index' => 0 } }
      let(:resource_scope) do
        Cuprum::Collections::Scope.new({ 'book_id' => 0 })
      end
      let(:unique_scope) do
        Cuprum::Collections::Scope.new({ 'book_id' => 1 })
      end
      let(:non_matching_scope) do
        Cuprum::Collections::Scope.new({ 'book_id' => 2 })
      end
      let(:expected_author) { nil }
      let(:expected_book) do
        books_data.find { |book| book['id'] == expected_chapter['book_id'] }
      end
      let(:expected_chapter) do
        if resource.plural? || resource.scope.type == :all
          return chapters_data.first
        end

        expected_unique_chapter
      end
      let(:expected_unique_chapter) do
        chapters_data.find { |chapter| chapter['book_id'] == 1 }
      end
    end

    deferred_context 'with resource parameters for a Chapter command' do
      let(:default_contract) do
        Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
          key 'chapter_index',  Stannum::Constraints::Presence.new
          key 'title',          Stannum::Constraints::Presence.new
        end
      end
      let(:original_attributes) { expected_chapter }
      let(:empty_attributes)    { { 'book' => nil, 'book_id' => nil } }
      let(:valid_attributes) do
        {
          'title'         => 'Introduction',
          'chapter_index' => 0
        }
      end
      let(:invalid_attributes)  { { 'title' => nil, 'chapter_index' => 0 } }
      let(:extra_attributes)    { { 'book_id' => 10 } }
    end
  end
end
