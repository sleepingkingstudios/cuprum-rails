# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/commands/resources/create_examples'

require 'support/examples/commands/books_examples'
require 'support/commands/orm/create'

# @note Integration test for command with custom value.
RSpec.describe Spec::Support::Commands::Orm::Create do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::CreateExamples
  include Spec::Support::Examples::Commands::BooksExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:entity_attributes) do
    call_command
      .value
      .records
      .first
  end
  let(:expected_value) do
    be_a(Spec::Support::Commands::Orm::Records).and have_attributes(
      record_class: Hash,
      records:      [expected_attributes]
    )
  end
  let(:persisted_value) { expected_attributes }

  include_deferred 'with parameters for a Book command'

  include_deferred 'should implement the Create command'
end
