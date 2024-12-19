# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/commands/resources/index_examples'

require 'support/commands/chapters/index'
require 'support/commands/chapters_examples'

# @note Integration test for command with custom logic.
RSpec.describe Spec::Support::Commands::Chapters::Index do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::IndexExamples
  include Spec::Support::Commands::ChaptersExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:expected_data) do
    matching_data.map do |chapter|
      book    = books_data.find { |item| item['id'] == chapter['book_id'] }
      author  =
        authors_data.find { |item| item['id'] == book['author_id'] }
      chapter = chapter.merge(
        'author' => author,
        'book'   => book
      )
    end
  end

  def call_command
    command.call(authors: authors_data, **command_options)
  end

  include_deferred 'with parameters for a Chapter command'

  include_deferred 'should implement the Index command'
end
