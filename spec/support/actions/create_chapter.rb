# frozen_string_literal: true

require 'cuprum/rails/actions/create'

require 'support/actions'
require 'support/book'
require 'support/chapter'

module Spec::Support::Actions
  class CreateChapter < Cuprum::Rails::Actions::Create
    private

    def book
      @book ||= find_book.value
    end

    def book_id
      params['book_id']
    end

    def books_collection
      repository['books']
    end

    def build_response
      super().merge('book' => book)
    end

    def create_entity(attributes:)
      attributes = attributes.merge({
        'book'          => book,
        'chapter_index' => next_chapter_index
      })

      super(attributes: attributes)
    end

    def find_book
      books_collection.find_one.call(primary_key: book_id)
    end

    def find_required_entities
      require_book
    end

    def next_chapter_index
      (next_chapter_query.first&.chapter_index || -1) + 1
    end

    def next_chapter_query
      native_query = book.chapters.select(:chapter_index)
      Cuprum::Rails::Query
        .new(
          Book,
          native_query: native_query
        )
        .order(chapter_index: :desc)
        .limit(1)
    end

    def process(request:)
      @book    = nil
      @book_id = nil

      super
    end

    def require_book
      @book || find_book
    end

    def require_book_id
      return if book_id.present?

      failure(
        Cuprum::Rails::Errors::MissingPrimaryKey.new(
          primary_key:   :id,
          resource_name: 'book'
        )
      )
    end

    def validate_parameters
      step { require_book_id }
      step { require_resource_params }
    end
  end
end
