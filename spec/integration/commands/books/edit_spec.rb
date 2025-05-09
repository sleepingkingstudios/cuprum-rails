# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/commands/resources/edit_examples'

require 'support/examples/commands/books_examples'
require 'support/commands/books/edit'

# @note Integration test for command with custom attributes.
RSpec.describe Spec::Support::Commands::Books::Edit do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::EditExamples
  include Spec::Support::Examples::Commands::BooksExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:expected_attributes) do
    attributes = tools.hash_tools.convert_keys_to_strings(matched_attributes)
    slug       =
      tools.str.underscore(attributes.fetch('title', '')).tr('_', '-')

    original_attributes
      .merge(
        tools.hash_tools.convert_keys_to_strings(matched_attributes)
      )
      .merge('slug' => slug)
  end

  include_deferred 'with parameters for a Book command'

  include_deferred 'should implement the Edit command'
end
