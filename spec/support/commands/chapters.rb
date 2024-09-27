# frozen_string_literal: true

require 'support/commands'

module Spec::Support::Commands
  module Chapters
    AUTHORS_FIXTURES = [
      {
        'id'   => 0,
        'name' => 'Tamsyn Muir'
      }
    ].map(&:freeze).freeze

    BOOKS_FIXTURES = [
      {
        'id'        => 0,
        'author_id' => 0,
        'title'     => 'Gideon the Ninth',
        'series'    => 'The Locked Tomb'
      },
      {
        'id'        => 1,
        'author_id' => 0,
        'title'     => 'Harrow the Ninth',
        'series'    => 'The Locked Tomb'
      },
      {
        'id'        => 2,
        'author_id' => 0,
        'title'     => 'Nona the Ninth',
        'author'    => 'Tamsyn Muir',
        'series'    => 'The Locked Tomb'
      }
    ].map(&:freeze).freeze

    CHAPTERS_FIXTURES = [
      {
        'id'            => 0,
        'book_id'       => 0,
        'title'         => 'Prologue',
        'chapter_index' => 0
      },
      {
        'id'            => 1,
        'book_id'       => 0,
        'title'         => 'Chapter 1',
        'chapter_index' => 1
      },
      {
        'id'            => 2,
        'book_id'       => 1,
        'title'         => 'Introduction',
        'chapter_index' => 0
      }
    ].map(&:freeze).freeze
  end
end
