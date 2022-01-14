# frozen_string_literal: true

require 'cuprum/rails/actions/edit'

require 'support/actions'

module Spec::Support::Actions
  class NewChapter < Cuprum::Rails::Actions::New
    private

    attr_reader :books

    def books_collection
      repository['books']
    end

    def build_response
      super.merge('books' => books)
    end

    def find_books
      books_collection.find_matching.call(order: :title)
    end

    def perform_action
      @books = step { find_books }.to_a

      super
    end

    def process(request:)
      @books = nil

      super
    end
  end
end
