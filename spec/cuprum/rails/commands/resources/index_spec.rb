# frozen_string_literal: true

require 'cuprum/rails/commands/resources/index'
require 'cuprum/rails/rspec/deferred/commands/resources/index_examples'

require 'support/examples/commands/books_examples'

RSpec.describe Cuprum::Rails::Commands::Resources::Index do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::IndexExamples
  include Spec::Support::Examples::Commands::BooksExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:resource_options) { super().merge(default_order: 'id') }

  include_deferred 'with parameters for a Book command'

  include_deferred 'should implement the ResourceCommand methods'

  include_deferred 'should implement the Index command'
end
