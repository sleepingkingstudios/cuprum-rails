# frozen_string_literal: true

require 'cuprum/rails/rspec/contracts/actions/show_contracts'

require 'support/actions/show_book'
require 'support/book'
require 'support/chapter'

# @note Integration spec for
#   Cuprum::Rails::RSpec::Contracts::Actions::ShowContracts.
RSpec.describe Spec::Support::Actions::ShowBook do
  include Cuprum::Rails::RSpec::Contracts::Actions::ShowContracts

  subject(:action) { described_class.new }

  let(:repository) do
    Cuprum::Rails::Records::Repository
      .new
      .tap { |repo| repo.create(entity_class: Book) }
      .tap { |repo| repo.create(entity_class: Chapter) }
  end
  let(:resource) do
    Cuprum::Rails::Resource.new(entity_class: Book)
  end
  let(:book) do
    Book.new(
      'title'  => 'Gideon the Ninth',
      'author' => 'Tamsyn Muir',
      'series' => 'The Locked Tomb'
    )
  end

  before(:example) { book.save! }

  include_contract 'should be a show action',
    existing_entity:           -> { book },
    expected_value_on_success: lambda { |hsh|
      hsh.merge('chapters' => [])
    }

  context 'when the book has many chapters' do
    let(:chapters) do
      Array.new(3) do |index|
        Chapter.new(
          book:,
          title:         "Chapter #{1 + index}",
          chapter_index: index
        )
      end
    end

    before(:example) { chapters.each(&:save!) }

    include_contract 'should be a show action',
      existing_entity:           -> { book },
      expected_value_on_success: lambda { |hsh|
        hsh.merge('chapters' => chapters.sort_by(&:title))
      }
  end
end
