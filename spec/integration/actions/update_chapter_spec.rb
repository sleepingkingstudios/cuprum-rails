# frozen_string_literal: true

require 'cuprum/rails/rspec/actions/update_contracts'

require 'support/actions/update_chapter'
require 'support/book'
require 'support/chapter'

# @note Integration spec for Cuprum::Rails::RSpec::Actions::UpdateContracts.
RSpec.describe Spec::Support::Actions::UpdateChapter do
  include Cuprum::Rails::RSpec::Actions::UpdateContracts

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

  include_contract 'update action contract',
    existing_entity:           -> { chapter },
    invalid_attributes:        { 'title' => '' },
    valid_attributes:          { 'title' => 'Chapter Title' },
    expected_value_on_success: lambda { |hsh|
      hsh.merge('book' => book)
    }
end
