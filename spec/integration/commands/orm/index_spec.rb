# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/commands/resources/index_examples'

require 'support/examples/commands/books_examples'
require 'support/commands/orm/index'

# @note Integration test for command with custom value.
RSpec.describe Spec::Support::Commands::Orm::Index do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::IndexExamples
  include Spec::Support::Examples::Commands::BooksExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:expected_value) do
    be_a(Spec::Support::Commands::Orm::Records).and have_attributes(
      record_class: Hash,
      records:      matching_data
    )
  end

  include_deferred 'with parameters for a Book command'

  include_deferred 'should implement the Index command'
end
