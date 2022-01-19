# frozen_string_literal: true

require 'cuprum/rails/actions/destroy'

require 'support/actions'
require 'support/book'
require 'support/chapter'

module Spec::Support::Actions
  class DestroyBook < Cuprum::Rails::Actions::Destroy
    private

    attr_reader :chapters

    def build_response
      super().merge('chapters' => chapters)
    end

    def chapters_collection
      repository['chapters']
    end

    def destroy_chapter(chapter_id:)
      chapters_collection.destroy_one.call(primary_key: chapter_id)
    end

    def destroy_chapters
      @chapters.each do |chapter|
        step { destroy_chapter(chapter_id: chapter.id) }
      end
    end

    def find_chapters
      book_id = entity.id

      step do
        chapters_collection
          .find_matching
          .call { { 'book_id' => book_id } }
      end
        .to_a
    end

    def perform_action
      transaction do
        super

        @chapters = step { find_chapters }

        step { destroy_chapters }
      end
    end

    def process(request:)
      @chapters = nil

      super
    end
  end
end
