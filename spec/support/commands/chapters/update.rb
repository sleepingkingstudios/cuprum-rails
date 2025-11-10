# frozen_string_literal: true

require 'cuprum/rails/commands/resources/update'

require 'support/commands/chapters'

module Spec::Support::Commands::Chapters
  class Update < Cuprum::Rails::Commands::Resources::Update
    private

    attr_reader :author

    attr_reader :book

    def assign_author(author:, chapter:)
      chapter.merge('author' => author)
    end

    def assign_book(book:, chapter:)
      chapter.merge('book' => book)
    end

    def books_collection
      repository.find(qualified_name: 'books')
    end

    def find_book(book_id)
      books_collection
        .find_matching
        .call(where: { 'id' => book_id })
        .value
        .first
    end

    def process(author: nil, **options)
      @author = author

      super(**options)
    end

    def require_entity(**options)
      chapter = step { super(**options) }
      book_id = chapter['book_id']
      book    = step { find_book(book_id) }
      chapter = assign_book(book:, chapter:)

      assign_author(author:, chapter:)
    end
  end
end
