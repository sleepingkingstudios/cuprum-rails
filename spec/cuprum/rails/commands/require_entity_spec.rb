# frozen_string_literal: true

require 'cuprum/rails/commands/require_entity'

require 'support/book'

RSpec.describe Cuprum::Rails::Commands::RequireEntity do
  subject(:command) { described_class.new(collection:, **options) }

  let(:collection) do
    Cuprum::Rails::Records::Collection.new(entity_class: Book)
  end
  let(:options) { { require_primary_key: true } }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:collection, :require_primary_key)
    end
  end

  describe '#call' do
    let(:parameters) { {} }

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:entity, :primary_key)
        .and_any_keywords
    end

    define_method :call_command do
      command.call(**parameters)
    end

    context 'when initialized with require_primary_key: false' do
      let(:options) { super().merge(require_primary_key: false) }

      describe 'with entity: value' do
        let(:entity) do
          Book.new(title: 'Gideon the Ninth', author: 'Tamsyn Muir')
        end
        let(:parameters) { { entity: } }

        it 'should return a passing result with the entity' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(entity)
        end
      end

      context 'when there are no values matching the resource scope' do
        let(:expected_error) do
          Cuprum::Collections::Errors::NotFound.new(
            collection_name: collection.name,
            query:           collection.query
          )
        end

        it 'should return a failing result' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      context 'when there is one value matching the resource scope' do
        let(:entity) do
          Book.new(title: 'Gideon the Ninth', author: 'Tamsyn Muir')
        end

        before(:example) do
          result = collection.insert_one.call(entity:)

          raise result.error.message if result.error
        end

        it 'should return a passing result with the entity' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(entity)
        end
      end

      context 'when there are many values matching the resource scope' do
        let(:entities) do
          [
            Book.new(title: 'Gideon the Ninth', author: 'Tamsyn Muir'),
            Book.new(title: 'Harrow the Ninth', author: 'Tamsyn Muir'),
            Book.new(title: 'Nona the Ninth',   author: 'Tamsyn Muir')
          ]
        end
        let(:expected_error) do
          Cuprum::Collections::Errors::NotUnique.new(
            collection_name: collection.name,
            query:           collection.query
          )
        end

        before(:example) do
          entities.each do |entity|
            result = collection.insert_one.call(entity:)

            raise result.error.message if result.error
          end
        end

        it 'should return a failing result' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end

    context 'when initialized with require_primary_key: true' do
      let(:options) { super().merge(require_primary_key: true) }

      describe 'with entity: nil and primary_key: nil' do
        let(:parameters) { {} }
        let(:expected_error) do
          collection
            .find_one
            .call(primary_key: nil)
            .error
        end

        it 'should return a failing result' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with entity: value' do
        let(:entity) do
          Book.new(title: 'Gideon the Ninth', author: 'Tamsyn Muir')
        end
        let(:parameters) { { entity: } }

        it 'should return a passing result with the entity' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(entity)
        end
      end

      describe 'with primary_key: invalid value' do
        let(:primary_key) { (Book.last&.id || -1) + 1 }
        let(:parameters)  { { primary_key: } }
        let(:expected_error) do
          collection
            .find_one
            .call(primary_key:)
            .error
        end

        it 'should return a failing result' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with primary_key: valid value' do
        let(:entity) do
          entity = Book.new(title: 'Gideon the Ninth', author: 'Tamsyn Muir')
          result = collection.insert_one.call(entity:)

          raise result.error.message if result.error

          result.value
        end
        let(:primary_key) { entity.id }
        let(:parameters)  { { primary_key: } }

        it 'should return a passing result with the entity' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(entity)
        end
      end
    end

    context 'with a subclass with custom behavior' do
      let(:described_class) { Spec::CustomRequireEntity }
      let(:options)         { super().merge(require_primary_key: true) }

      # rubocop:disable RSpec/DescribedClass
      example_class 'Spec::CustomRequireEntity',
        Cuprum::Rails::Commands::RequireEntity \
      do |klass|
        klass.define_method :find_entity_by_identifier do |title|
          matching = step { collection.find_matching.call(where: { title: }) }
          matching = matching.to_a

          matching.empty? ? failure(entity_not_found_error) : matching.first
        end
      end
      # rubocop:enable RSpec/DescribedClass

      describe 'with entity: nil and primary_key: nil' do
        let(:parameters) { {} }
        let(:expected_error) do
          Cuprum::Collections::Errors::NotFound.new(
            collection_name: collection.name,
            query:           collection.query
          )
        end

        it 'should return a failing result' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with entity: value' do
        let(:entity) do
          Book.new(title: 'Gideon the Ninth', author: 'Tamsyn Muir')
        end
        let(:parameters) { { entity: } }

        it 'should return a passing result with the entity' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(entity)
        end
      end

      describe 'with primary_key: invalid value' do
        let(:primary_key) { 'Alecto the Ninth' }
        let(:parameters)  { { primary_key: } }
        let(:expected_error) do
          Cuprum::Collections::Errors::NotFound.new(
            collection_name: collection.name,
            query:           collection.query
          )
        end

        it 'should return a failing result' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with primary_key: valid value' do
        let(:entity) do
          entity = Book.new(title: 'Gideon the Ninth', author: 'Tamsyn Muir')
          result = collection.insert_one.call(entity:)

          raise result.error.message if result.error

          result.value
        end
        let(:primary_key) { entity.title }
        let(:parameters)  { { primary_key: } }

        it 'should return a passing result with the entity' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(entity)
        end
      end
    end
  end

  describe '#collection' do
    include_examples 'should define reader', :collection, -> { collection }
  end

  describe '#find_entity_by_identifier' do
    it 'should define the method' do
      expect(command).to respond_to(:find_entity_by_identifier).with(1).argument
    end

    describe 'with nil' do
      let(:parameters) { {} }
      let(:expected_error) do
        collection
          .find_one
          .call(primary_key: nil)
          .error
      end

      it 'should return a failing result' do
        expect(command.find_entity_by_identifier(nil))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with an invalid value' do
      let(:primary_key) { (Book.last&.id || -1) + 1 }
      let(:expected_error) do
        collection
          .find_one
          .call(primary_key:)
          .error
      end

      it 'should return a failing result' do
        expect(command.find_entity_by_identifier(primary_key))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a valid value' do
      let(:entity) do
        entity = Book.new(title: 'Gideon the Ninth', author: 'Tamsyn Muir')
        result = collection.insert_one.call(entity:)

        raise result.error.message if result.error

        result.value
      end
      let(:primary_key) { entity.id }

      it 'should return a passing result with the entity' do
        expect(command.find_entity_by_identifier(primary_key))
          .to be_a_passing_result
          .with_value(entity)
      end
    end
  end

  describe '#find_matching_entity' do
    it 'should define the method' do
      expect(command).to respond_to(:find_matching_entity).with(0).arguments
    end

    context 'when there are no values matching the resource scope' do
      let(:expected_error) do
        Cuprum::Collections::Errors::NotFound.new(
          collection_name: collection.name,
          query:           collection.query
        )
      end

      it 'should return a failing result' do
        expect(command.find_matching_entity)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    context 'when there is one value matching the resource scope' do
      let(:entity) do
        Book.new(title: 'Gideon the Ninth', author: 'Tamsyn Muir')
      end

      before(:example) do
        result = collection.insert_one.call(entity:)

        raise result.error.message if result.error
      end

      it 'should return a passing result with the entity' do
        expect(command.find_matching_entity)
          .to be_a_passing_result
          .with_value(entity)
      end
    end

    context 'when there are many values matching the resource scope' do
      let(:entities) do
        [
          Book.new(title: 'Gideon the Ninth', author: 'Tamsyn Muir'),
          Book.new(title: 'Harrow the Ninth', author: 'Tamsyn Muir'),
          Book.new(title: 'Nona the Ninth',   author: 'Tamsyn Muir')
        ]
      end
      let(:expected_error) do
        Cuprum::Collections::Errors::NotUnique.new(
          collection_name: collection.name,
          query:           collection.query
        )
      end

      before(:example) do
        entities.each do |entity|
          result = collection.insert_one.call(entity:)

          raise result.error.message if result.error
        end
      end

      it 'should return a failing result' do
        expect(command.find_matching_entity)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end
  end

  describe '#require_primary_key?' do
    include_examples 'should define predicate', :require_primary_key?

    context 'when initialized with require_primary_key: false' do
      let(:options) { super().merge(require_primary_key: false) }

      it { expect(command.require_primary_key?).to be false }
    end

    context 'when initialized with require_primary_key: true' do
      let(:options) { super().merge(require_primary_key: true) }

      it { expect(command.require_primary_key?).to be true }
    end
  end
end
