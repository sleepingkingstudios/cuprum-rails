# frozen_string_literal: true

require 'cuprum/rails/commands/resources/new'

require 'support/commands/chapters'

module Spec::Support::Commands::Chapters
  class Edit < Cuprum::Rails::Commands::Resources::Edit
    private

    attr_reader :author

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

    def update_entity(attributes:, entity:)
      book_id = entity['book_id']
      book    = step { find_book(book_id) }

      attributes = attributes.merge(
        book:,
        book_id: book&.then { |hsh| hsh['id'] }
      )

      entity = step { super }
      entity = assign_book(book:, chapter: entity)

      assign_author(author:, chapter: entity)
    end
  end
end
