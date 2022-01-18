# frozen_string_literal: true

require 'cuprum/rails/repository'
require 'cuprum/rails/rspec/actions/create_contracts'

require 'support/actions/create_chapter'
require 'support/book'
require 'support/chapter'

# @note Integration spec for Cuprum::Rails::RSpec::Actions::CreateContracts.
RSpec.describe Spec::Support::Actions::CreateChapter do
  include Cuprum::Rails::RSpec::Actions::CreateContracts

  subject(:action) do
    described_class.new(repository: repository, resource: resource)
  end

  let(:repository) do
    Cuprum::Rails::Repository
      .new
      .tap { |repo| repo.create(record_class: Book) }
  end
  let(:resource) do
    Cuprum::Rails::Resource.new(
      collection:           repository.find_or_create(record_class: Chapter),
      permitted_attributes: %i[title],
      resource_class:       Chapter
    )
  end
  let(:book) do
    Book
      .new(
        title:  'Gideon the Ninth',
        author: 'Tammsyn Muir'
      )
      .tap(&:save!)
  end
  let(:book_id)            { book.id }
  let(:next_chapter_index) { 0 }

  include_contract 'create action contract',
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
