# frozen_string_literal: true

require 'cuprum/rails/commands/resources/edit'
require 'cuprum/rails/rspec/deferred/commands/resources/edit_examples'

require 'support/examples/commands/books_examples'

RSpec.describe Cuprum::Rails::Commands::Resources::Edit do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::EditExamples
  include Spec::Support::Examples::Commands::BooksExamples

  subject(:command) { described_class.new(repository:, resource:) }

  include_deferred 'with parameters for a Book command'

  include_deferred 'should implement the ResourceCommand methods'

  include_deferred 'should implement the Edit command'
end
