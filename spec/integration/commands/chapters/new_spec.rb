# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/commands/resources/new_examples'

require 'support/commands/chapters/new'
require 'support/examples/commands/chapters_examples'

# @note Integration test for command with custom logic.
RSpec.describe Spec::Support::Commands::Chapters::New do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::NewExamples
  include Spec::Support::Examples::Commands::ChaptersExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:book) { nil }

  def call_command
    command.call(attributes: matched_attributes, book:)
  end

  include_deferred 'with parameters for a Chapter command'

  include_deferred 'with resource parameters for a Chapter command'

  include_deferred 'should implement the New command' do
    describe 'with book: value' do
      let(:book) { Spec::Support::Commands::Chapters::BOOKS_FIXTURES.first }
      let(:matched_attributes) { configured_valid_attributes }
      let(:expected_attributes) do
        empty_attributes
          .merge(matched_attributes)
          .merge(
            'book'    => book,
            'book_id' => book['id']
          )
      end

      include_deferred 'should build the entity'
    end
  end
end
