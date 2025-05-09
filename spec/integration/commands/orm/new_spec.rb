# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/commands/resources/new_examples'

require 'support/examples/commands/books_examples'
require 'support/commands/orm/new'

# @note Integration test for command with custom value.
RSpec.describe Spec::Support::Commands::Orm::New do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::NewExamples
  include Spec::Support::Examples::Commands::BooksExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:expected_value) do
    be_a(Spec::Support::Commands::Orm::Records).and have_attributes(
      record_class: Hash,
      records:      [expected_attributes]
    )
  end

  include_deferred 'with parameters for a Book command'

  include_deferred 'should implement the New command'
end
