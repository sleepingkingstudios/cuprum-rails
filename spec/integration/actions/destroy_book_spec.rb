# frozen_string_literal: true

require 'cuprum/rails/rspec/contracts/actions/destroy_contracts'

require 'support/actions/destroy_book'
require 'support/book'
require 'support/chapter'

# @note Integration spec for
#   Cuprum::Rails::RSpec::Contracts::Actions::DestroyContracts.
RSpec.describe Spec::Support::Actions::DestroyBook do
  include Cuprum::Rails::RSpec::Contracts::Actions::DestroyContracts

  subject(:action) { described_class.new }

  let(:repository) do
    Cuprum::Rails::Repository
      .new
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

  include_contract 'should be a destroy action',
    existing_entity:           -> { book },
    expected_value_on_success: lambda { |hsh|
      hsh.merge('chapters' => [])
    }

  context 'when the book has many chapters' do
    let(:chapters) do
      Array.new(3) do |index|
        Chapter.new(book: book, chapter_index: index, title: "Chapter #{index}")
      end
    end

    before(:example) { chapters.each(&:save!) }

    include_contract 'should destroy the entity',
      existing_entity: -> { book },
      expected_value:  lambda { |hsh|
        hsh.merge('chapters' => chapters)
      } \
      do
        it 'should destroy the chapters' do
          expect { call_action }
            .to change(Chapter, :count)
            .by(-3)
        end
      end
  end
end
