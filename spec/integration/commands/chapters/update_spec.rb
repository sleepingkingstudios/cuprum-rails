# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/commands/resources/update_examples'

require 'support/commands/chapters/update'
require 'support/examples/commands/chapters_examples'

# @note Integration test for command with custom logic.
RSpec.describe Spec::Support::Commands::Chapters::Update do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::UpdateExamples
  include Spec::Support::Examples::Commands::ChaptersExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:expected_attributes) do
    original_attributes.merge(
      'author'        => expected_author,
      'book'          => expected_book,
      'title'         => 'Introduction',
      'chapter_index' => 0
    )
  end
  let(:original_attributes) do
    expected_chapter.merge(
      'author' => expected_author,
      'book'   => expected_book
    )
  end

  def call_command
    command.call(attributes:, author:, entity:, primary_key:)
  end

  include_deferred 'with parameters for a Chapter command'

  include_deferred 'with query parameters for a Chapter command'

  include_deferred 'with resource parameters for a Chapter command'

  include_deferred 'should implement the Update command'

  describe '#call' do
    describe 'with author: value' do
      let(:author) { Spec::Support::Commands::Chapters::AUTHORS_FIXTURES.last }
      let(:expected_attributes) do
        super().merge('author' => author)
      end

      before(:example) do
        repository.create(
          default_contract:,
          qualified_name:   resource.qualified_name
        )
      end

      include_deferred 'with a valid entity' do
        include_deferred 'should update the entity'
      end
    end
  end
end
