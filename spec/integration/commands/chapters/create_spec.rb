# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/commands/resources/create_examples'

require 'support/commands/chapters/create'
require 'support/examples/commands/chapters_examples'

# @note Integration test for command with custom logic.
RSpec.describe Spec::Support::Commands::Chapters::Create do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::CreateExamples
  include Spec::Support::Examples::Commands::ChaptersExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:book) { nil }

  def call_command
    command.call(attributes:, book:)
  end

  include_deferred 'with parameters for a Chapter command'

  include_deferred 'with resource parameters for a Chapter command'

  include_deferred 'should implement the Create command'

  describe '#call' do
    describe 'with book: value' do
      let(:book) { Spec::Support::Commands::Chapters::BOOKS_FIXTURES.first }
      let(:expected_attributes) do
        super().merge(
          'book'    => book,
          'book_id' => book['id']
        )
      end

      before(:example) do
        repository.create(
          default_contract:,
          qualified_name:   resource.qualified_name
        )
      end

      include_deferred 'should create the entity'
    end
  end
end
