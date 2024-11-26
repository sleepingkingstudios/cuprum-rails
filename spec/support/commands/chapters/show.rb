# frozen_string_literal: true

require 'cuprum/rails/commands/resources/new'

require 'support/commands/chapters'

module Spec::Support::Commands::Chapters
  class Show < Cuprum::Rails::Commands::Resources::Show
    private

    attr_reader :book

    def assign_author(author:, chapter:)
      chapter.merge('author' => author)
    end

    def assign_book(book:, chapter:)
      chapter.merge('book' => book)
    end

    def books_collection
      repository.find_or_create(qualified_name: 'books')
    end

    def find_book(book_id)
      books_collection
        .find_matching
        .call(where: { 'id' => book_id })
        .value
        .first
    end

    def process(author: nil, **options)
      chapter = step { super(**options) }
      book_id = chapter['book_id']
      book    = step { find_book(book_id) }
      chapter = assign_book(book:, chapter:)

      assign_author(author:, chapter:)
    end
  end
end
