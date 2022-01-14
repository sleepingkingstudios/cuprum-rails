# frozen_string_literal: true

require 'cuprum/rails/rspec/actions/new_contracts'

require 'support/actions/new_chapter'
require 'support/book'
require 'support/chapter'

# @note Integration spec for Cuprum::Rails::RSpec::Actions::EditContracts.
RSpec.describe Spec::Support::Actions::NewChapter do
  include Cuprum::Rails::RSpec::Actions::NewContracts

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

  include_contract 'new action contract',
    expected_value_on_success: lambda { |hsh|
      hsh.merge('books' => [])
    }

  context 'when there are many books' do
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

    include_contract 'should build the entity',
      expected_value: lambda { |hsh|
        hsh.merge('books' => expected_books)
      }
  end
end
