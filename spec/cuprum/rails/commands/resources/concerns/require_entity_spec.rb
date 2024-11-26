# frozen_string_literal: true

require 'cuprum/collections/basic/repository'

require 'cuprum/rails/commands/resource_command'
require 'cuprum/rails/commands/resources/concerns/require_entity'
require 'cuprum/rails/resource'
require 'cuprum/rails/rspec/deferred/commands/resources_examples'

RSpec.describe Cuprum::Rails::Commands::Resources::Concerns::RequireEntity do
  include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:described_class) { Spec::ExampleCommand }
  let(:repository)      { Cuprum::Collections::Basic::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(name: 'books', **resource_options)
  end
  let(:resource_options) { { primary_key_name: 'id' } }

  example_class 'Spec::ExampleCommand',
    Cuprum::Rails::Commands::ResourceCommand \
  do |klass|
    klass.include \
      Cuprum::Rails::Commands::Resources::Concerns::RequireEntity # rubocop:disable RSpec/DescribedClass

    klass.define_method(:process) do |**parameters|
      require_entity(**parameters)
    end
  end

  describe '#call' do
    def call_command
      command.call(entity:, primary_key:)
    end

    include_deferred 'should require entity'

    context 'with a command subclass with require_primary_key: false' do
      before(:example) do
        Spec::ExampleCommand.define_method(:require_primary_key?) { false }
      end

      context 'when initialized with a plural resource' do
        let(:resource_options) { super().merge(plural: true) }

        include_deferred 'should require entity by scoped uniqueness'
      end
    end

    context 'with a command subclass with require_primary_key: true' do
      before(:example) do
        Spec::ExampleCommand.define_method(:require_primary_key?) { true }
      end

      context 'when initialized with a singular resource' do
        let(:resource_options) { super().merge(plural: false) }

        include_deferred 'should require entity by primary key'
      end
    end
  end
end
