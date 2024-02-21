# frozen_string_literal: true

require 'cuprum/rails/rspec/contracts/actions/index_contracts'

require 'support/actions/index_chapters'
require 'support/book'
require 'support/chapter'

# @note Integration spec for Cuprum::Rails::RSpec::Actions::IndexContracts.
RSpec.describe Spec::Support::Actions::IndexChapters do
  include Cuprum::Rails::RSpec::Contracts::Actions::IndexContracts

  subject(:action) { described_class.new }

  let(:repository) do
    Cuprum::Rails::Repository
      .new
      .tap { |repo| repo.create(entity_class: Book) }
  end
  let(:resource) do
    Cuprum::Rails::Resource.new(
      entity_class:  Chapter,
      default_order: :id
    )
  end
  let(:books) do
    [
      Book.new(
        'title'  => 'Gideon the Ninth',
        'author' => 'Tamsyn Muir',
        'series' => 'The Locked Tomb'
      ),
      Book.new(
        'title'  => 'Harrow the Ninth',
        'author' => 'Tamsyn Muir',
        'series' => 'The Locked Tomb'
      ),
      Book.new(
        'title'  => 'Nona the Ninth',
        'author' => 'Tamsyn Muir',
        'series' => 'The Locked Tomb'
      )
    ]
  end
  let(:chapters) do
    [
      Chapter.new(
        'book'          => books[0],
        'title'         => 'Prologue',
        'chapter_index' => 0
      ),
      Chapter.new(
        'book'          => books[0],
        'title'         => 'Chapter 1',
        'chapter_index' => 1
      ),
      Chapter.new(
        'book'          => books[1],
        'title'         => 'Introduction',
        'chapter_index' => 0
      )
    ]
  end

  before(:example) do
    books.each(&:save!)
    chapters.each(&:save!)
  end

  include_contract 'should be an index action',
    existing_entities:         -> { chapters.sort_by(&:id) },
    expected_value_on_success: lambda { |hsh|
      hsh.merge('books' => books[0..1])
    }

  describe 'with parameters' do
    let(:params) do
      {
        'order' => 'title',
        'where' => { 'book_id' => books[0].id }
      }
    end
    let(:expected_chapters) do
      chapters
        .select { |chapter| chapter.book == books[0] }
        .sort_by(&:title)
    end

    include_contract 'should be an index action',
      existing_entities:         -> { expected_chapters },
      expected_value_on_success: lambda { |hsh|
        hsh.merge('books' => books[0..0])
      },
      params:                    -> { params }
  end
end
