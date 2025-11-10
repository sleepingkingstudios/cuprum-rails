# frozen_string_literal: true

require 'cuprum/rails/commands/resource_command'
require 'cuprum/rails/rspec/deferred/commands/resources_examples'

RSpec.describe Cuprum::Rails::Commands::ResourceCommand do
  include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:repository) { Cuprum::Collections::Basic::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(name: 'books', **resource_options)
  end
  let(:resource_options) { {} }

  include_deferred 'should implement the ResourceCommand methods'
end
