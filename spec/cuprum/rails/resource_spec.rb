# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/relation_contracts'

require 'cuprum/rails/resource'

require 'support/book'
require 'support/tome'

RSpec.describe Cuprum::Rails::Resource do
  include Cuprum::Collections::RSpec::Contracts::RelationContracts

  subject(:resource) { described_class.new(**constructor_options) }

  shared_context 'with a plural parent resource' do
    let(:authors_resource)    { described_class.new(name: 'authors') }
    let(:constructor_options) { super().merge(parent: authors_resource) }
  end

  shared_context 'with a singular parent resource' do
    let(:library_resource) do
      described_class.new(name: 'library', singular: true)
    end
    let(:constructor_options) { super().merge(parent: library_resource) }
  end

  shared_context 'with multiple ancestor resources' do
    let(:authors_resource) do
      described_class.new(name: 'authors')
    end
    let(:series_resource) do
      described_class.new(
        name:          'series',
        singular_name: 'series',
        parent:        authors_resource
      )
    end
    let(:constructor_options) { super().merge(parent: series_resource) }
  end

  let(:name)                { 'books' }
  let(:constructor_options) { { name: } }

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
            name:,
            permitted_attributes: Object.new.freeze
          )
        end
          .to raise_error ArgumentError, error_message
      end
    end
  end

  include_contract 'should be a relation',
    cardinality: true

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
      let(:constructor_options) { super().merge(actions:) }
      let(:expected)            { Set.new(actions) }

      it { expect(resource.actions).to be == expected }
    end

    context 'when initialized with singular: true' do
      let(:constructor_options) { super().merge(singular: true) }
      let(:expected)            { Set.new(described_class::SINGULAR_ACTIONS) }

      it { expect(resource.actions).to be == expected }

      context 'when initialized with actions: an Array of Strings' do
        let(:actions)             { %w[show launch recover] }
        let(:constructor_options) { super().merge(actions:) }
        let(:expected)            { Set.new(actions) }

        it { expect(resource.actions).to be == expected }
      end
    end
  end

  describe '#ancestors' do
    include_examples 'should define reader', :ancestors, -> { [resource] }

    wrap_context 'with a plural parent resource' do
      let(:expected) { [authors_resource, resource] }

      it { expect(resource.ancestors).to be == expected }
    end

    wrap_context 'with a singular parent resource' do
      let(:expected) { [library_resource, resource] }

      it { expect(resource.ancestors).to be == expected }
    end

    wrap_context 'with multiple ancestor resources' do
      let(:expected) { [authors_resource, series_resource, resource] }

      it { expect(resource.ancestors).to be == expected }
    end
  end

  describe '#base_path' do
    include_examples 'should define reader', :base_path, '/books'

    context 'when initialized with base_path: a string' do
      let(:base_path)           { '/path/to/books' }
      let(:constructor_options) { super().merge(base_path:) }

      it { expect(resource.base_path).to be == base_path }
    end

    context 'when initialized with singular: true' do
      let(:constructor_options) { super().merge(singular: true) }

      it { expect(resource.base_path).to be == '/book' }
    end

    wrap_context 'with a plural parent resource' do
      let(:expected) { '/authors/:author_id/books' }

      it { expect(resource.base_path).to be == expected }

      context 'when initialized with base_path: a string' do
        let(:base_path)           { '/path/to/books' }
        let(:constructor_options) { super().merge(base_path:) }

        it { expect(resource.base_path).to be == base_path }
      end

      context 'when initialized with singular: true' do
        let(:constructor_options) { super().merge(singular: true) }
        let(:expected)            { '/authors/:author_id/book' }

        it { expect(resource.base_path).to be == expected }
      end
    end

    wrap_context 'with a singular parent resource' do
      let(:expected) { '/library/books' }

      it { expect(resource.base_path).to be == expected }

      context 'when initialized with base_path: a string' do
        let(:base_path)           { '/path/to/books' }
        let(:constructor_options) { super().merge(base_path:) }

        it { expect(resource.base_path).to be == base_path }
      end

      context 'when initialized with singular: true' do
        let(:constructor_options) { super().merge(singular: true) }
        let(:expected)            { '/library/book' }

        it { expect(resource.base_path).to be == expected }
      end
    end

    wrap_context 'with multiple ancestor resources' do
      let(:expected) { '/authors/:author_id/series/:series_id/books' }

      it { expect(resource.base_path).to be == expected }

      context 'when initialized with base_path: a string' do
        let(:base_path)           { '/path/to/books' }
        let(:constructor_options) { super().merge(base_path:) }

        it { expect(resource.base_path).to be == base_path }
      end

      context 'when initialized with singular: true' do
        let(:constructor_options) { super().merge(singular: true) }
        let(:expected) do
          '/authors/:author_id/series/:series_id/book'
        end

        it { expect(resource.base_path).to be == expected }
      end
    end
  end

  describe '#default_order' do
    include_examples 'should define reader', :default_order, -> { {} }

    context 'when initialized with a default order' do
      let(:default_order)       { { title: :asc } }
      let(:constructor_options) { super().merge(default_order:) }

      it { expect(resource.default_order).to be == default_order }
    end
  end

  describe '#each_ancestor' do
    it { expect(resource.each_ancestor).to be_a Enumerator }

    it { expect(resource.each_ancestor.to_a).to be == [resource] }

    it 'should yield the resource' do
      expect { |block| resource.each_ancestor(&block) }
        .to yield_successive_args(resource)
    end

    wrap_context 'with a plural parent resource' do
      let(:expected) { [authors_resource, resource] }

      it { expect(resource.each_ancestor.to_a).to be == expected }

      it 'should yield the resource and its ancestors' do
        expect { |block| resource.each_ancestor(&block) }
          .to yield_successive_args(*expected)
      end
    end

    wrap_context 'with a singular parent resource' do
      let(:expected) { [library_resource, resource] }

      it { expect(resource.each_ancestor.to_a).to be == expected }

      it 'should yield the resource and its ancestors' do
        expect { |block| resource.each_ancestor(&block) }
          .to yield_successive_args(*expected)
      end
    end

    wrap_context 'with multiple ancestor resources' do
      let(:expected) { [authors_resource, series_resource, resource] }

      it { expect(resource.each_ancestor.to_a).to be == expected }

      it 'should yield the resource and its ancestors' do
        expect { |block| resource.each_ancestor(&block) }
          .to yield_successive_args(*expected)
      end
    end
  end

  describe '#parent' do
    include_examples 'should define reader', :parent, nil

    wrap_context 'with a plural parent resource' do
      it { expect(resource.parent).to be == authors_resource }
    end

    wrap_context 'with a singular parent resource' do
      it { expect(resource.parent).to be == library_resource }
    end

    wrap_context 'with multiple ancestor resources' do
      it { expect(resource.parent).to be == series_resource }
    end
  end

  describe '#permitted_attributes' do
    include_examples 'should define reader', :permitted_attributes, nil

    context 'when initialized with permitted attributes' do
      let(:permitted_attributes) { %i[title author] }
      let(:constructor_options) do
        super().merge(permitted_attributes:)
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
      let(:constructor_options) { super().merge(entity_class: Tome) }

      it { expect(resource.primary_key_name).to be == 'uuid' }
    end
  end

  describe '#primary_key_type' do
    context 'when initialized with a class with UUID primary key' do
      let(:constructor_options) { super().merge(entity_class: Tome) }

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

    it { expect(resource.routes.parent_path).to be == '/' }

    it { expect(resource.routes.wildcards).to be == {} }

    context 'when initialized with base_path: a string' do
      let(:base_path)           { '/path/to/books' }
      let(:constructor_options) { super().merge(base_path:) }

      it { expect(resource.routes.base_path).to be == base_path }

      it { expect(resource.routes.parent_path).to be == '/' }
    end

    context 'when initialized with routes: a Routes object' do
      let(:routes)              { Spec::Routes.new(base_path: '/books') }
      let(:constructor_options) { super().merge(routes:) }

      example_class 'Spec::Routes', Cuprum::Rails::Routes

      it { expect(resource.routes).to be_a Spec::Routes }

      it { expect(resource.routes.wildcards).to be == {} }

      describe 'with wildcards: a Hash' do
        let(:wildcards) { { 'key' => 'value' } }

        it 'should return the routes' do
          expect(resource.routes(wildcards:)).to be_a Spec::Routes
        end

        it 'should set the wildcards' do
          expect(resource.routes(wildcards:).wildcards)
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

      it { expect(resource.routes.parent_path).to be == '/' }

      it { expect(resource.routes.wildcards).to be == {} }
    end

    wrap_context 'with a plural parent resource' do
      let(:parent_path) { '/authors/:author_id' }
      let(:expected)    { "#{parent_path}/books" }

      it { expect(resource.routes.base_path).to be == expected }

      describe 'with wildcards: a Hash' do
        let(:wildcards) { { 'key' => 'value', 'author_id' => '0' } }
        let(:expected)  { '/authors/0' }

        it 'should generate the parent path' do
          expect(resource.routes.with_wildcards(wildcards).parent_path)
            .to be == expected
        end
      end

      context 'when initialized with base_path: a string' do
        let(:base_path)           { '/path/to/books' }
        let(:constructor_options) { super().merge(base_path:) }

        it { expect(resource.routes.base_path).to be == base_path }

        describe 'with wildcards: a Hash' do
          let(:wildcards) { { 'key' => 'value', 'author_id' => '0' } }
          let(:expected)  { '/authors/0' }

          it 'should generate the parent path' do
            expect(resource.routes.with_wildcards(wildcards).parent_path)
              .to be == expected
          end
        end
      end

      context 'when initialized with singular: true' do
        let(:constructor_options) { super().merge(singular: true) }
        let(:expected)            { "#{parent_path}/book" }

        it { expect(resource.routes.base_path).to be == expected }

        describe 'with wildcards: a Hash' do
          let(:wildcards) { { 'key' => 'value', 'author_id' => '0' } }
          let(:expected)  { '/authors/0' }

          it 'should generate the parent path' do
            expect(resource.routes.with_wildcards(wildcards).parent_path)
              .to be == expected
          end
        end
      end
    end

    wrap_context 'with a singular parent resource' do
      let(:parent_path) { '/library' }
      let(:expected)    { "#{parent_path}/books" }

      it { expect(resource.routes.base_path).to be == expected }

      it { expect(resource.routes.parent_path).to be == parent_path }

      context 'when initialized with base_path: a string' do
        let(:base_path)           { '/path/to/books' }
        let(:constructor_options) { super().merge(base_path:) }

        it { expect(resource.routes.base_path).to be == base_path }

        it { expect(resource.routes.parent_path).to be == parent_path }
      end

      context 'when initialized with singular: true' do
        let(:constructor_options) { super().merge(singular: true) }
        let(:expected)            { "#{parent_path}/book" }

        it { expect(resource.routes.base_path).to be == expected }

        it { expect(resource.routes.parent_path).to be == parent_path }
      end
    end

    wrap_context 'with multiple ancestor resources' do
      let(:parent_path) { '/authors/:author_id/series/:series_id' }
      let(:expected)    { "#{parent_path}/books" }

      it { expect(resource.routes.base_path).to be == expected }

      describe 'with wildcards: a Hash' do
        let(:wildcards) do
          { 'key' => 'value', 'author_id' => '0', 'series_id' => '1' }
        end
        let(:expected) { '/authors/0/series/1' }

        it 'should generate the parent path' do
          expect(resource.routes.with_wildcards(wildcards).parent_path)
            .to be == expected
        end
      end

      context 'when initialized with base_path: a string' do
        let(:base_path)           { '/path/to/books' }
        let(:constructor_options) { super().merge(base_path:) }

        it { expect(resource.routes.base_path).to be == base_path }

        describe 'with wildcards: a Hash' do
          let(:wildcards) do
            { 'key' => 'value', 'author_id' => '0', 'series_id' => '1' }
          end
          let(:expected) { '/authors/0/series/1' }

          it 'should generate the parent path' do
            expect(resource.routes.with_wildcards(wildcards).parent_path)
              .to be == expected
          end
        end
      end

      context 'when initialized with singular: true' do
        let(:constructor_options) { super().merge(singular: true) }
        let(:expected)            { "#{parent_path}/book" }

        it { expect(resource.routes.base_path).to be == expected }

        describe 'with wildcards: a Hash' do
          let(:wildcards) do
            { 'key' => 'value', 'author_id' => '0', 'series_id' => '1' }
          end
          let(:expected) { '/authors/0/series/1' }

          it 'should generate the parent path' do
            expect(resource.routes.with_wildcards(wildcards).parent_path)
              .to be == expected
          end
        end
      end
    end
  end
end
