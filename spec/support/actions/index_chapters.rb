# frozen_string_literal: true

require 'set'

require 'cuprum/rails/actions/index'

require 'support/actions'

module Spec::Support::Actions
  class IndexChapters < Cuprum::Rails::Actions::Index
    private

    attr_reader :books

    def books_collection
      repository['books']
    end

    def build_response
      super.merge('books' => books)
    end

    def find_book_ids
      entities
        .each
        .with_object(Set.new) do |chapter, book_ids|
          book_ids << chapter.book_id
        end
        .to_a
    end

    def find_books
      book_ids = find_book_ids

      books_collection.find_many.call(primary_keys: book_ids)
    end

    def perform_action
      step { super }

      @books = step { find_books }
    end

    def process(**)
      @books = nil

      super
    end
  end
end
