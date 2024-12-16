# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/commands/resources/edit_examples'

require 'support/commands/chapters/edit'
require 'support/commands/chapters_examples'

# @note Integration test for command with custom logic.
RSpec.describe Spec::Support::Commands::Chapters::Edit do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::EditExamples
  include Spec::Support::Commands::ChaptersExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:expected_attributes) do
    original_attributes.merge(
      'author'        => expected_author,
      'book'          => expected_book,
      'title'         => 'Introduction',
      'chapter_index' => 0
    )
  end

  def call_command
    command.call(attributes:, author:, entity:, primary_key:)
  end

  include_deferred 'with parameters for a Chapter command'

  include_deferred 'with query parameters for a Chapter command'

  include_deferred 'with resource parameters for a Chapter command'

  include_deferred 'should implement the Edit command'
end
