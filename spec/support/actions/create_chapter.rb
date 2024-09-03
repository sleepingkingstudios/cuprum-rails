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

    def books_collection
      repository['books']
    end

    def book_id
      params['book_id']
    end

    def build_response
      super.merge('book' => book)
    end

    def create_entity(attributes:)
      attributes = attributes.merge({
        'book'          => book,
        'chapter_index' => next_chapter_index
      })

      super
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
          native_query:
        )
        .order(chapter_index: :desc)
        .limit(1)
    end

    def parameters_contract
      return @parameters_contract if @parameters_contract

      parent_contract = super

      @parameters_contract =
        Cuprum::Rails::Constraints::ParametersContract.new do
          concat parent_contract

          key 'book_id', Stannum::Constraints::Presence.new
        end
    end

    def process(**)
      @book    = nil
      @book_id = nil

      super
    end

    def require_book
      @book || find_book
    end
  end
end
