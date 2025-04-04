# frozen_string_literal: true

require 'cuprum/rails/commands/resources/new'
require 'cuprum/rails/rspec/deferred/commands/resources/new_examples'

require 'support/examples/commands/books_examples'
require 'support/examples/commands/resources_examples'

RSpec.describe Cuprum::Rails::Commands::Resources::New do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::NewExamples
  include Spec::Support::Examples::Commands::BooksExamples
  include Spec::Support::Examples::Commands::ResourcesExamples

  subject(:command) { described_class.new(repository:, resource:) }

  include_deferred 'with parameters for a Book command'

  include_deferred 'should implement the resource command methods'

  include_deferred 'should implement the New command'
end
