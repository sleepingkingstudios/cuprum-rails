# frozen_string_literal: true

require 'cuprum/rails/commands/resources/new'

require 'support/commands/chapters'

module Spec::Support::Commands::Chapters
  class New < Cuprum::Rails::Commands::Resources::New
    private

    attr_reader :book

    def build_entity(attributes:)
      attributes = attributes.merge(
        book:,
        book_id: book&.then { |entity| entity['id'] }
      )

      super
    end

    def process(book: nil, **options)
      @book = book

      super
    end
  end
end
