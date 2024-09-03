# frozen_string_literal: true

require 'cuprum/rails/actions/create'

require 'support/actions'
require 'support/book'
require 'support/chapter'

module Spec::Support::Actions
  class CreateBook < Cuprum::Rails::Actions::Create
    private

    attr_reader :chapters

    def build_response
      super.merge('chapters' => chapters)
    end

    def chapter_params
      params.fetch('book', {}).fetch('chapters', [])
    end

    def chapters_collection
      repository['chapters']
    end

    def create_chapter(attributes)
      chapter = step do
        chapters_collection.build_one.call(attributes: attributes)
      end

      step { chapters_collection.validate_one.call(entity: chapter) }

      step { chapters_collection.insert_one.call(entity: chapter) }
    end

    def create_chapters
      chapter_params
        .map
        .with_index do |chapter_attributes, index|
          create_chapter(
            chapter_attributes.merge('book' => entity, 'chapter_index' => index)
          )
        end
        .sort_by(&:id)
    end

    def perform_action
      transaction do
        step { super }

        @chapters = create_chapters
      end
    end

    def process(**)
      @chapters = nil

      super
    end
  end
end
