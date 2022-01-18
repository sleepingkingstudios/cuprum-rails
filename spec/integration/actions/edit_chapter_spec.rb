# frozen_string_literal: true

require 'cuprum/rails/rspec/actions/edit_contracts'

require 'support/actions/edit_chapter'
require 'support/book'
require 'support/chapter'

# @note Integration spec for Cuprum::Rails::RSpec::Actions::EditContracts.
RSpec.describe Spec::Support::Actions::EditChapter do
  include Cuprum::Rails::RSpec::Actions::EditContracts

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
      collection:     repository.find_or_create(record_class: Chapter),
      resource_class: Chapter
    )
  end
  let(:book) do
    Book.new(
      'title'  => 'Gideon the Ninth',
      'author' => 'Tamsyn Muir',
      'series' => 'The Locked Tomb'
    )
  end
  let(:chapter) do
    Chapter.new(
      'book'          => book,
      'title'         => 'Prologue',
      'chapter_index' => 0
    )
  end

  before(:example) do
    book.save!
    chapter.save!
  end

  include_contract 'edit action contract',
    existing_entity:           -> { chapter },
    expected_value_on_success: lambda { |hsh|
      hsh.merge('books' => [book])
    }

  context 'when there are many books' do
    let(:books) do
      [
        book,
        Book.new(
          'title'  => 'Harrow the Ninth',
          'author' => 'Tamsyn Muir',
          'series' => 'The Locked Tomb'
        ),
        Book.new(
          'title'  => 'Nona the Ninth',
          'author' => 'Tamsyn Muir',
          'series' => 'The Locked Tomb'
        ),
        Book.new(
          'title'  => 'Alecto the Ninth',
          'author' => 'Tamsyn Muir',
          'series' => 'The Locked Tomb'
        )
      ]
    end
    let(:expected_books) { books.sort_by(&:title) }

    before(:example) { books.each(&:save!) }

    include_contract 'should find the entity',
      existing_entity: -> { chapter },
      expected_value:  lambda { |hsh|
        hsh.merge('books' => expected_books)
      }
  end
end
