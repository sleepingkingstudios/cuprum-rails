# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/commands/resources/show_examples'

require 'support/commands/chapters/show'
require 'support/examples/commands/chapters_examples'

# @note Integration test for command with custom logic.
RSpec.describe Spec::Support::Commands::Chapters::Show do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::ShowExamples
  include Spec::Support::Examples::Commands::ChaptersExamples

  subject(:command) { described_class.new(repository:, resource:) }

  def call_command
    command.call(author:, entity:, primary_key:)
  end

  include_deferred 'with parameters for a Chapter command'

  include_deferred 'with query parameters for a Chapter command'

  include_deferred 'should implement the Show command'

  describe '#call' do
    describe 'with an author' do
      let(:author) do
        authors_data
          .find { |author| author['id'] == expected_book['author_id'] }
      end
      let(:expected_author) { author }

      include_deferred 'with a valid entity' do
        include_deferred 'should find the entity'
      end
    end
  end
end
