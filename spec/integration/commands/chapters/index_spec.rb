# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/commands/resources/index_examples'

require 'support/commands/chapters/index'
require 'support/examples/commands/chapters_examples'

# @note Integration test for command with custom logic.
RSpec.describe Spec::Support::Commands::Chapters::Index do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::IndexExamples
  include Spec::Support::Examples::Commands::ChaptersExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:expected_tags) { [] }
  let(:expected_data) do
    matching_data.map do |chapter|
      book    = books_data.find { |item| item['id'] == chapter['book_id'] }
      chapter = chapter.merge(
        'book' => book,
        'tags' => expected_tags
      )
    end
  end

  define_method :call_command do
    command.call(authors: authors_data, **command_options)
  end

  include_deferred 'with parameters for a Chapter command'

  include_deferred 'with query parameters for a Chapter command'

  include_deferred 'should implement the Index command' do
    describe 'with tags: value' do
      let(:tags)            { %w[category:genre-fiction classic] }
      let(:expected_tags)   { tags }
      let(:command_options) { super().merge(tags:) }

      include_deferred 'when the collection has many items'

      include_deferred 'should find the matching collection data'
    end
  end
end
