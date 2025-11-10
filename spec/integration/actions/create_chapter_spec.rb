# frozen_string_literal: true

require 'cuprum/rails/records/repository'
require 'cuprum/rails/rspec/contracts/actions/create_contracts'

require 'support/actions/create_chapter'
require 'support/book'
require 'support/chapter'

# @note Integration spec for
#   Cuprum::Rails::RSpec::Contracts::Actions::CreateContracts.
RSpec.describe Spec::Support::Actions::CreateChapter do
  include Cuprum::Rails::RSpec::Contracts::Actions::CreateContracts

  subject(:action) { described_class.new }

  let(:repository) do
    Cuprum::Rails::Records::Repository
      .new
      .tap { |repo| repo.create(entity_class: Book) }
      .tap { |repo| repo.create(entity_class: Chapter) }
  end
  let(:resource) do
    Cuprum::Rails::Resource.new(
      entity_class:         Chapter,
      permitted_attributes: %i[title]
    )
  end
  let(:book) do
    Book
      .new(
        title:  'Gideon the Ninth',
        author: 'Tamsyn Muir'
      )
      .tap(&:save!)
  end
  let(:book_id)            { book.id }
  let(:next_chapter_index) { 0 }

  include_contract 'should be a create action',
    params:                         lambda {
      { 'book_id' => book_id }
    },
    invalid_attributes:             {
      'title' => ''
    },
    valid_attributes:               {
      'title' => 'Chapter Title'
    },
    expected_attributes_on_failure: lambda { |hsh|
      hsh.merge(
        'book'          => book,
        'chapter_index' => next_chapter_index
      )
    },
    expected_attributes_on_success: lambda { |hsh|
      hsh.merge(
        'book'          => book,
        'chapter_index' => next_chapter_index
      )
    },
    expected_value_on_success:      lambda { |hsh|
      hsh.merge('book' => book)
    }

  context 'when the book has many chapters' do
    let(:next_chapter_index) { 3 }

    before(:example) do
      book.chapters.create(title: 'Chapter 1', chapter_index: 0)
      book.chapters.create(title: 'Chapter 2', chapter_index: 1)
      book.chapters.create(title: 'Chapter 3', chapter_index: 2)
    end

    include_contract 'should create the entity',
      params:              lambda {
        { 'book_id' => book_id }
      },
      valid_attributes:    { 'title' => 'Chapter Title' },
      expected_attributes: lambda { |hsh|
        hsh.merge(
          'book'          => book,
          'chapter_index' => next_chapter_index
        )
      },
      expected_value:      lambda { |hsh|
        hsh.merge('book' => book)
      }
  end
end
