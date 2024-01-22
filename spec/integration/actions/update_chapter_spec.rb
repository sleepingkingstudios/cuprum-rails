# frozen_string_literal: true

require 'cuprum/rails/rspec/contracts/actions/update_contracts'

require 'support/actions/update_chapter'
require 'support/book'
require 'support/chapter'

# @note Integration spec for
#   Cuprum::Rails::RSpec::Contracts::Actions::UpdateContracts.
RSpec.xdescribe Spec::Support::Actions::UpdateChapter do
  include Cuprum::Rails::RSpec::Contracts::Actions::UpdateContracts

  subject(:action) { described_class.new }

  let(:repository) do
    Cuprum::Rails::Repository
      .new
      .tap { |repo| repo.create(entity_class: Book) }
  end
  let(:resource) do
    Cuprum::Rails::Resource.new(
      entity_class:         Chapter,
      permitted_attributes: %i[title]
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
      'title'         => 'Chapter 0',
      'chapter_index' => 0
    )
  end

  before(:example) do
    book.save!
    chapter.save!
  end

  include_contract 'should be an update action',
    existing_entity:           -> { chapter },
    invalid_attributes:        { 'title' => '' },
    valid_attributes:          { 'title' => 'Chapter Title' },
    expected_value_on_success: lambda { |hsh|
      hsh.merge('book' => book)
    }
end
