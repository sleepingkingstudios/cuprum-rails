# frozen_string_literal: true

require 'cuprum/rails/records/repository'
require 'cuprum/rails/resource'
require 'cuprum/rails/rspec/deferred/commands/resources/new_examples'

require 'support/book'
require 'support/commands/chapters/new'

# @note Integration test for command with custom logic.
RSpec.describe Spec::Support::Commands::Chapters::New do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::NewExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:repository) { Cuprum::Collections::Basic::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(name: 'chapters', **resource_options)
  end
  let(:resource_options) { { permitted_attributes: %w[title chapter_index] } }
  let(:attributes) do
    {
      'title'         => 'Introduction',
      'chapter_index' => 0
    }
  end
  let(:empty_attributes) { { 'book' => nil, 'book_id' => nil } }
  let(:extra_attributes) { { 'book_id' => 10 } }
  let(:expected_attributes) do
    empty_attributes.merge(
      'title'         => 'Introduction',
      'chapter_index' => 0
    )
  end

  include_deferred 'should implement the New command'

  describe '#call' do
    describe 'with book: value' do
      let(:book) { Spec::Support::Commands::Chapters::BOOKS_FIXTURES.first }
      let(:expected_attributes) do
        super().merge(
          'book'    => book,
          'book_id' => book['id']
        )
      end

      def call_command
        command.call(attributes:, book:)
      end

      include_deferred 'should build the entity'
    end
  end
end
