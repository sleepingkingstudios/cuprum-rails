# frozen_string_literal: true

require 'cuprum/rails/commands/resources/show'
require 'cuprum/rails/rspec/deferred/commands/resources/show_examples'

require 'support/examples/commands/books_examples'
require 'support/examples/commands/resources_examples'

RSpec.describe Cuprum::Rails::Commands::Resources::Show do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::ShowExamples
  include Spec::Support::Examples::Commands::BooksExamples
  include Spec::Support::Examples::Commands::ResourcesExamples

  subject(:command) { described_class.new(repository:, resource:) }

  include_deferred 'with parameters for a Book command'

  include_deferred 'should implement the resource command methods'

  include_deferred 'should implement the Show command'
end
