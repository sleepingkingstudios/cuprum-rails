# frozen_string_literal: true

require 'cuprum/rails/actions/show'

require 'support/actions'

module Spec::Support::Actions
  class ShowBook < Cuprum::Rails::Actions::Show
    private

    attr_reader :chapters

    def build_response
      super.merge('chapters' => chapters)
    end

    def chapters_collection
      repository['chapters']
    end

    def find_chapters
      book_id = entity.id

      chapters_collection.find_matching.call(order: :title) do
        { book_id: book_id }
      end
    end

    def perform_action
      step { super }

      @chapters = step { find_chapters }.to_a
    end

    def process(**)
      @chapters = nil

      super
    end
  end
end
