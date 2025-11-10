# frozen_string_literal: true

require 'cuprum/rails/commands/resources/index'

require 'support/commands/chapters'

module Spec::Support::Commands::Chapters
  class Index < Cuprum::Rails::Commands::Resources::Index
    private

    def assign_books(books:, chapters:)
      chapters.map do |chapter|
        book = books.find { |item| item['id'] == chapter['book_id'] }

        chapter.merge('book' => book)
      end
    end

    def books_collection
      repository.find(qualified_name: 'books')
    end

    def find_books(chapters)
      book_ids = chapters.reduce(Set.new) do |set, chapter|
        set << chapter['book_id']
      end
      scope = Cuprum::Collections::Scope.new do |scope|
        { id: scope.one_of(book_ids.to_a) }
      end

      books_collection.find_matching.call(where: scope)
    end

    def process(tags: [], **options)
      chapters = step { super(**options) }
      chapters = chapters.map { |chapter| chapter.merge('tags' => tags) }
      books    = step { find_books(chapters) }

      assign_books(books:, chapters:)
    end
  end
end
