# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/commands/resources/update_examples'

require 'support/commands/chapters/update'
require 'support/examples/commands/chapters_examples'

# @note Integration test for command with custom logic.
RSpec.describe Spec::Support::Commands::Chapters::Update do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::UpdateExamples
  include Spec::Support::Examples::Commands::ChaptersExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:original_attributes) do
    expected_chapter.merge(
      'author' => expected_author,
      'book'   => expected_book
    )
  end

  define_method :call_command do
    attributes = defined?(matched_attributes) ? matched_attributes : {}

    command.call(
      attributes:,
      author:,
      entity:      defined?(entity)      ? entity      : nil,
      primary_key: defined?(primary_key) ? primary_key : nil
    )
  end

  include_deferred 'with parameters for a Chapter command'

  include_deferred 'with query parameters for a Chapter command'

  include_deferred 'with resource parameters for a Chapter command'

  include_deferred 'should implement the Update command' do
    describe 'with author: value' do
      let(:author) { Spec::Support::Commands::Chapters::AUTHORS_FIXTURES.last }
      let(:matched_attributes) do
        configured_valid_attributes
      end
      let(:expected_attributes) do
        original_attributes
          .merge(tools.hash_tools.convert_keys_to_strings(matched_attributes))
          .merge('author' => author)
      end

      include_deferred 'with a valid entity' do
        include_deferred 'should update the entity'
      end
    end
  end
end
