# frozen_string_literal: true

require 'cuprum/rails/commands/resources/edit'
require 'cuprum/rails/rspec/deferred/commands/resources/edit_examples'

require 'support/examples/commands/books_examples'
require 'support/examples/commands/resources_examples'

RSpec.describe Cuprum::Rails::Commands::Resources::Edit do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::EditExamples
  include Spec::Support::Examples::Commands::BooksExamples
  include Spec::Support::Examples::Commands::ResourcesExamples

  subject(:command) { described_class.new(repository:, resource:) }

  include_deferred 'with parameters for a Book command'

  include_deferred 'with query parameters for a Book command'

  include_deferred 'should implement the resource command methods'

  include_deferred 'should implement the Edit command'
end
