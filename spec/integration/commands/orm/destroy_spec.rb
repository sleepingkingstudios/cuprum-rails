# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/commands/resources/destroy_examples'

require 'support/examples/commands/books_examples'
require 'support/commands/orm/destroy'

# @note Integration test for command with custom value.
RSpec.describe Spec::Support::Commands::Orm::Destroy do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::DestroyExamples
  include Spec::Support::Examples::Commands::BooksExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:expected_value) do
    be_a(Spec::Support::Commands::Orm::Records).and have_attributes(
      record_class: Hash,
      records:      [matched_entity]
    )
  end

  include_deferred 'with parameters for a Book command'

  include_deferred 'should implement the Destroy command'
end
