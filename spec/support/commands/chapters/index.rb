# frozen_string_literal: true

require 'cuprum/rails/commands/resources/index'

require 'support/commands/chapters'

module Spec::Support::Commands::Chapters
  class Index < Cuprum::Rails::Commands::Resources::Index
    private

    def assign_authors(authors:, chapters:)
      chapters.map do |chapter|
        author =
          authors.find { |item| item['id'] == chapter['book']['author_id'] }

        chapter.merge('author' => author)
      end
    end

    def assign_books(books:, chapters:)
      chapters.map do |chapter|
        book = books.find { |item| item['id'] == chapter['book_id'] }

        chapter.merge('book' => book)
      end
    end

    def books_collection
      repository.find_or_create(qualified_name: 'books')
    end

    def find_books(book_ids)
      where = Cuprum::Collections::Scope.new do |scope|
        { id: scope.one_of(book_ids) }
      end

      books_collection.find_matching.call(where:)
    end

    def process(authors: [], **options)
      chapters = step { super(**options) }
      book_ids = chapters.reduce(Set.new) do |set, chapter|
        set << chapter['book_id']
      end
      books    = step { find_books(book_ids.to_a) }
      chapters = assign_books(books:, chapters:)

      assign_authors(authors:, chapters:)
    end
  end
end
