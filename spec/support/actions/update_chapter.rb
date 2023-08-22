# frozen_string_literal: true

require 'cuprum/rails/actions/update'

require 'support/actions'

module Spec::Support::Actions
  class UpdateChapter < Cuprum::Rails::Actions::Update
    private

    attr_reader :book

    def books_collection
      repository['books']
    end

    def build_response
      super.merge('book' => book)
    end

    def find_book
      book_id = entity.book_id

      books_collection.find_one.call(primary_key: book_id)
    end

    def perform_action
      step { super }

      @book = step { find_book }
    end

    def process(**)
      @book = nil

      super
    end
  end
end
