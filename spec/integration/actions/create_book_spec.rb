# frozen_string_literal: true

require 'cuprum/rails/records/repository'
require 'cuprum/rails/rspec/contracts/actions/create_contracts'

require 'support/actions/create_book'
require 'support/book'
require 'support/chapter'

# @note Integration spec for
#   Cuprum::Rails::RSpec::Contracts::Actions::CreateContracts.
RSpec.describe Spec::Support::Actions::CreateBook do
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
      entity_class:         Book,
      permitted_attributes: %i[title author series]
    )
  end

  include_contract 'should be a create action',
    invalid_attributes:        {
      'title' => 'Gideon the Ninth'
    },
    valid_attributes:          {
      'title'  => 'Gideon the Ninth',
      'author' => 'Tamsyn Muir',
      'series' => 'The Locked Tomb'
    },
    expected_value_on_success: ->(hsh) { hsh.merge('chapters' => []) }

  context 'with chapter parameters' do
    let(:chapter_params) do
      [
        { 'title' => 'Chapter 1' },
        { 'title' => 'Chapter 2' },
        { 'title' => 'Chapter 3' }
      ]
    end
    let(:expected_chapters) do
      Chapter
        .where(book: Book.where(title: 'Gideon the Ninth').first)
        .order(:id)
    end

    include_contract 'should create the entity',
      valid_attributes:    lambda {
        {
          'title'    => 'Gideon the Ninth',
          'author'   => 'Tamsyn Muir',
          'series'   => 'The Locked Tomb',
          'chapters' => chapter_params
        }
      },
      expected_attributes: {
        'title'  => 'Gideon the Ninth',
        'author' => 'Tamsyn Muir',
        'series' => 'The Locked Tomb'
      },
      expected_value:      lambda { |hsh|
        hsh.merge('chapters' => expected_chapters)
      } \
      do
        it 'should create the chapters' do
          expect { call_action }
            .to change(Chapter, :count)
            .by(chapter_params.count)
        end
      end
  end
end
