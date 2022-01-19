# frozen_string_literal: true

require 'cuprum/rails/rspec/actions/destroy_contracts'

require 'support/actions/destroy_book'
require 'support/book'
require 'support/chapter'

# @note Integration spec for Cuprum::Rails::RSpec::Actions::CreateContracts.
RSpec.describe Spec::Support::Actions::DestroyBook do
  include Cuprum::Rails::RSpec::Actions::DestroyContracts

  subject(:action) do
    described_class.new(repository: repository, resource: resource)
  end

  let(:repository) do
    Cuprum::Rails::Repository
      .new
      .tap { |repo| repo.create(record_class: Chapter) }
  end
  let(:resource) do
    Cuprum::Rails::Resource.new(
      collection:     repository.find_or_create(record_class: Book),
      resource_class: Book
    )
  end
  let(:book) do
    Book.new(
      'title'  => 'Gideon the Ninth',
      'author' => 'Tamsyn Muir',
      'series' => 'The Locked Tomb'
    )
  end

  before(:example) { book.save! }

  include_contract 'destroy action contract',
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
          expect { action.call(request: request) }
            .to change(Chapter, :count)
            .by(-3)
        end
      end
  end
end
