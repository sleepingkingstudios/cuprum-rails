# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/relation_contracts'

require 'cuprum/rails/resource'

require 'support/book'
require 'support/tome'

RSpec.describe Cuprum::Rails::Resource do
  include Cuprum::Collections::RSpec::Contracts::RelationContracts

  subject(:resource) { described_class.new(**constructor_options) }

  let(:name)                { 'books' }
  let(:constructor_options) { { name: name } }

  example_class 'Grimoire',         'Book'
  example_class 'Spec::ScopedBook', 'Book'

  describe '::PLURAL_ACTIONS' do
    let(:expected) { %w[create destroy edit index new show update] }

    include_examples 'should define immutable constant',
      :PLURAL_ACTIONS,
      -> { expected }
  end

  describe '::SINGULAR_ACTIONS' do
    let(:expected) { %w[create destroy edit new show update] }

    include_examples 'should define immutable constant',
      :SINGULAR_ACTIONS,
      -> { expected }
  end

  describe '.new' do
    describe 'with permitted_attributes: an Object' do
      let(:error_message) do
        'keyword :permitted_attributes must be an Array or nil'
      end

      it 'should raise an exception' do # rubocop:disable RSpec/ExampleLength
        expect do
          described_class.new(
            name:                 name,
            permitted_attributes: Object.new.freeze
          )
        end
          .to raise_error ArgumentError, error_message
      end
    end
  end

  include_contract 'should be a relation',
    cardinality: true

  include_contract 'should disambiguate parameter',
    :entity_class,
    as:    :resource_class,
    value: Tome

  include_contract 'should disambiguate parameter',
    :name,
    as: :resource_name

  include_contract 'should disambiguate parameter',
    :singular_name,
    as: :singular_resource_name

  include_contract 'should define primary keys'

  include_contract 'should define cardinality'

  describe '#actions' do
    let(:expected) { Set.new(described_class::PLURAL_ACTIONS) }

    include_examples 'should define reader',
      :actions,
      -> { an_instance_of(Set) }

    it { expect(resource.actions).to be == expected }

    context 'when initialized with actions: an Array of Strings' do
      let(:actions)             { %w[index show launch recover] }
      let(:constructor_options) { super().merge(actions: actions) }
      let(:expected)            { Set.new(actions) }

      it { expect(resource.actions).to be == expected }
    end

    context 'when initialized with singular: true' do
      let(:constructor_options) { super().merge(singular: true) }
      let(:expected)            { Set.new(described_class::SINGULAR_ACTIONS) }

      it { expect(resource.actions).to be == expected }

      context 'when initialized with actions: an Array of Strings' do
        let(:actions)             { %w[show launch recover] }
        let(:constructor_options) { super().merge(actions: actions) }
        let(:expected)            { Set.new(actions) }

        it { expect(resource.actions).to be == expected }
      end
    end
  end

  describe '#base_path' do
    include_examples 'should define reader', :base_path, '/books'

    context 'when initialized with base_path: a string' do
      let(:base_path)           { '/path/to/books' }
      let(:constructor_options) { super().merge(base_path: base_path) }

      it { expect(resource.base_path).to be == base_path }
    end

    context 'when initialized with singular: true' do
      let(:constructor_options) { super().merge(singular: true) }

      it { expect(resource.base_path).to be == '/book' }
    end
  end

  describe '#default_order' do
    include_examples 'should define reader', :default_order, -> { {} }

    context 'when initialized with a default order' do
      let(:default_order)       { { title: :asc } }
      let(:constructor_options) { super().merge(default_order: default_order) }

      it { expect(resource.default_order).to be == default_order }
    end
  end

  describe '#permitted_attributes' do
    include_examples 'should define reader', :permitted_attributes, nil

    context 'when initialized with permitted attributes' do
      let(:permitted_attributes) { %i[title author] }
      let(:constructor_options) do
        super().merge(permitted_attributes: permitted_attributes)
      end

      it { expect(resource.permitted_attributes).to be == permitted_attributes }
    end
  end

  describe '#primary_key_name' do
    it 'should alias the method' do
      expect(resource)
        .to have_aliased_method(:primary_key_name)
        .as(:primary_key)
    end

    context 'when initialized with a class with UUID primary key' do
      let(:constructor_options) { super().merge(resource_class: Tome) }

      it { expect(resource.primary_key_name).to be == 'uuid' }
    end
  end

  describe '#primary_key_type' do
    context 'when initialized with a class with UUID primary key' do
      let(:constructor_options) { super().merge(resource_class: Tome) }

      it { expect(resource.primary_key_type).to be == String }
    end
  end

  describe '#routes' do
    it 'should define the method' do
      expect(resource)
        .to respond_to(:routes)
        .with(0).arguments
        .and_keywords(:wildcards)
    end

    it { expect(resource.routes).to be_a Cuprum::Rails::Routing::PluralRoutes }

    it { expect(resource.routes.base_path).to be == '/books' }

    it { expect(resource.routes.wildcards).to be == {} }

    describe 'when initialized with base_path: a string' do
      let(:base_path)           { '/path/to/books' }
      let(:constructor_options) { super().merge(base_path: base_path) }

      it { expect(resource.routes.base_path).to be == base_path }
    end

    context 'when initialized with routes: a Routes object' do
      let(:routes)              { Spec::Routes.new(base_path: '/books') }
      let(:constructor_options) { super().merge(routes: routes) }

      example_class 'Spec::Routes', Cuprum::Rails::Routes

      it { expect(resource.routes).to be_a Spec::Routes }

      it { expect(resource.routes.wildcards).to be == {} }

      describe 'with wildcards: a Hash' do
        let(:wildcards) { { 'key' => 'value' } }

        it 'should return the routes' do
          expect(resource.routes(wildcards: wildcards)).to be_a Spec::Routes
        end

        it 'should set the wildcards' do
          expect(resource.routes(wildcards: wildcards).wildcards)
            .to be == wildcards
        end
      end
    end

    context 'when initialized with singular: true' do
      let(:constructor_options) { super().merge(singular: true) }

      it 'should return a singular routes object' do
        expect(resource.routes).to be_a Cuprum::Rails::Routing::SingularRoutes
      end

      it { expect(resource.routes.base_path).to be == '/book' }

      it { expect(resource.routes.wildcards).to be == {} }
    end
  end
end
