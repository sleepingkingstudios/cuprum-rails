# frozen_string_literal: true

require 'cuprum/rails/resource'

require 'support/book'

RSpec.describe Cuprum::Rails::Resource do
  subject(:resource) { described_class.new(**constructor_options) }

  let(:resource_class)      { Book }
  let(:constructor_options) { { resource_class: resource_class } }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_any_keywords
    end

    describe 'with neither a resource_class or a resource_name' do
      let(:error_message) do
        'missing keyword :resource_class or :resource_name'
      end

      it 'should raise an exception' do
        expect { described_class.new }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with permitted_attributes: an object' do
      let(:error_message) do
        'keyword :permitted_attributes must be an Array or nil'
      end

      it 'should raise an exception' do # rubocop:disable RSpec/ExampleLength
        expect do
          described_class.new(
            permitted_attributes: Object.new.freeze,
            resource_name:        'books'
          )
        end
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '#base_url' do
    include_examples 'should define reader', :base_url, '/books'

    describe 'when initialized with base_url: a string' do
      let(:base_url)            { '/path/to/books' }
      let(:constructor_options) { super().merge(base_url: base_url) }

      it { expect(resource.base_url).to be == base_url }
    end

    describe 'when initialized with resource name: a string' do
      let(:resource_name)       { 'tomes' }
      let(:constructor_options) { super().merge(resource_name: resource_name) }

      it { expect(resource.base_url).to be == '/tomes' }
    end

    describe 'when initialized with singular: true' do
      let(:constructor_options) { super().merge(singular: true) }

      it { expect(resource.base_url).to be == '/book' }
    end
  end

  describe '#collection' do
    include_examples 'should define reader', :collection, nil

    context 'when initialized with a collection' do
      let(:collection) do
        Cuprum::Rails::Collection.new(record_class: resource_class)
      end
      let(:constructor_options) { super().merge(collection: collection) }

      it { expect(resource.collection).to be collection }
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

  describe '#options' do
    include_examples 'should define reader', :options, -> { {} }

    context 'when initialized with arbitrary options' do
      let(:constructor_options) { super().merge(key: 'value') }

      it { expect(resource.options).to be == { key: 'value' } }
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

  describe '#plural?' do
    include_examples 'should define predicate', :plural?, true

    context 'when initialized with singular: true' do
      let(:constructor_options) { super().merge(singular: true) }

      it { expect(resource.plural?).to be false }
    end
  end

  describe '#primary_key' do
    include_examples 'should define reader', :primary_key, 'id'

    context 'when initialized without a resource class' do
      let(:resource_name) { 'books' }
      let(:constructor_options) do
        super()
          .tap { |hsh| hsh.delete(:resource_class) }
          .merge(resource_name: resource_name)
      end

      it { expect(resource.primary_key).to be nil }
    end

    context 'when initialized with primary_key: a string' do
      let(:primary_key)         { 'uuid' }
      let(:constructor_options) { super().merge(primary_key: primary_key) }

      it { expect(resource.primary_key).to be == primary_key }
    end

    context 'when initialized with primary_key: a symbol' do
      let(:primary_key)         { :uuid }
      let(:constructor_options) { super().merge(primary_key: primary_key) }

      it { expect(resource.primary_key).to be == primary_key.to_s }
    end
  end

  describe '#resource_class' do
    include_examples 'should define reader',
      :resource_class,
      -> { resource_class }

    context 'when initialized without a resource class' do
      let(:resource_name) { 'books' }
      let(:constructor_options) do
        super()
          .tap { |hsh| hsh.delete(:resource_class) }
          .merge(resource_name: resource_name)
      end

      it { expect(resource.resource_class).to be nil }
    end
  end

  describe '#resource_name' do
    include_examples 'should define reader', :resource_name, 'books'

    context 'when initialized with resource_class: a namespaced class' do
      let(:constructor_options) do
        super().merge(resource_class: Spec::Grimoire)
      end

      example_class 'Spec::Grimoire'

      it { expect(resource.resource_name).to be == 'grimoires' }
    end

    context 'when initialized with resource_name: a string' do
      let(:resource_name)       { 'grimoires' }
      let(:constructor_options) { super().merge(resource_name: resource_name) }

      it { expect(resource.resource_name).to be == resource_name }
    end

    context 'when initialized with resource_name: a symbol' do
      let(:resource_name)       { :grimoires }
      let(:constructor_options) { super().merge(resource_name: resource_name) }

      it { expect(resource.resource_name).to be == resource_name.to_s }
    end

    context 'when initialized with singular: true' do
      let(:constructor_options) { super().merge(singular: true) }

      include_examples 'should define reader', :resource_name, 'book'

      context 'when initialized with resource_class: a namespaced class' do
        let(:constructor_options) do
          super().merge(resource_class: Spec::Grimoire)
        end

        example_class 'Spec::Grimoire'

        it { expect(resource.resource_name).to be == 'grimoire' }
      end
    end
  end

  describe '#singular?' do
    include_examples 'should define predicate', :singular?, false

    context 'when initialized with singular: true' do
      let(:constructor_options) { super().merge(singular: true) }

      it { expect(resource.singular?).to be true }
    end
  end

  describe '#singular_resource_name' do
    include_examples 'should define reader', :singular_resource_name, 'book'

    context 'when initialized with resource_class: a namespaced class' do
      let(:constructor_options) do
        super().merge(resource_class: Spec::Grimoire)
      end

      example_class 'Spec::Grimoire'

      it { expect(resource.singular_resource_name).to be == 'grimoire' }
    end

    context 'when initialized with resource_name: a string' do
      let(:resource_name)       { 'grimoires' }
      let(:constructor_options) { super().merge(resource_name: resource_name) }

      it 'should return the singular resource name' do
        expect(resource.singular_resource_name)
          .to be == resource_name.singularize
      end
    end

    context 'when initialized with resource_name: a symbol' do
      let(:resource_name)       { :grimoires }
      let(:constructor_options) { super().merge(resource_name: resource_name) }

      it 'should return the singular resource name' do
        expect(resource.singular_resource_name)
          .to be == resource_name.to_s.singularize
      end
    end

    context 'when initialized with singular: true' do
      let(:constructor_options) { super().merge(singular: true) }

      include_examples 'should define reader', :resource_name, 'book'

      context 'when initialized with resource_class: a namespaced class' do
        let(:constructor_options) do
          super().merge(resource_class: Spec::Grimoire)
        end

        example_class 'Spec::Grimoire'

        it { expect(resource.singular_resource_name).to be == 'grimoire' }
      end
    end

    context 'when initialized with singular_resource_name: a string' do
      let(:singular_resource_name) { 'grimoire' }
      let(:constructor_options) do
        super().merge(singular_resource_name: singular_resource_name)
      end

      it 'should return the singular resource name' do
        expect(resource.singular_resource_name)
          .to be == singular_resource_name
      end
    end

    context 'when initialized with singular_resource_name: a symbol' do
      let(:singular_resource_name) { :grimoire }
      let(:constructor_options) do
        super().merge(singular_resource_name: singular_resource_name)
      end

      it 'should return the singular resource name' do
        expect(resource.singular_resource_name)
          .to be == singular_resource_name.to_s
      end
    end
  end
end
