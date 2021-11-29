# frozen_string_literal: true

require 'cuprum/collections/basic/repository'
require 'cuprum/collections/rspec/repository_contract'

require 'cuprum/rails/repository'

require 'support/book'
require 'support/tome'

RSpec.describe Cuprum::Rails::Repository do
  subject(:repository) { described_class.new }

  shared_context 'when the repository has many collections' do
    let(:books_collection) do
      Cuprum::Rails::Collection.new(record_class: Book)
    end
    let(:magazines_collection) do
      Cuprum::Rails::Collection.new(
        collection_name: 'magazines',
        record_class:    Spec::Magazine
      )
    end
    let(:periodicals_collection) do
      Cuprum::Rails::Collection.new(
        collection_name: 'periodicals',
        record_class:    Spec::Periodical
      )
    end
    let(:collections) do
      {
        'books'       => books_collection,
        'magazines'   => magazines_collection,
        'periodicals' => periodicals_collection
      }
    end

    example_class 'Spec::Magazine',   ActiveRecord::Base

    example_class 'Spec::Periodical', ActiveRecord::Base

    before(:example) do
      repository <<
        books_collection <<
        magazines_collection <<
        periodicals_collection
    end
  end

  let(:example_collection) do
    Cuprum::Rails::Collection.new(record_class: Tome)
  end

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(0).arguments }
  end

  include_contract Cuprum::Collections::RSpec::REPOSITORY_CONTRACT

  describe '#add' do
    describe 'with an invalid collection' do
      let(:error_class) do
        described_class::InvalidCollectionError
      end
      let(:error_message) do
        "#{collection.inspect} is not a valid collection"
      end
      let(:collection) do
        Struct.new(:collection_name).new
      end

      it 'should raise an exception' do
        expect { repository.add(collection) }
          .to raise_error(error_class, error_message)
      end
    end
  end

  describe '#create' do
    let(:record_class) { Tome }
    let(:options)      { {} }

    def create_collection
      repository.create(
        record_class: record_class,
        **options
      )
    end

    it 'should define the method' do
      expect(repository)
        .to respond_to(:create)
        .with_keywords(:record_class)
        .and_any_keywords
    end

    describe 'with record_class: nil' do
      let(:record_class) { nil }
      let(:error_message) do
        'record class must be an ActiveRecord model'
      end

      it 'should raise an exception' do
        expect { repository.create(record_class: record_class) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with record_class: an object' do
      let(:record_class) { Object.new.freeze }
      let(:error_message) do
        'record class must be an ActiveRecord model'
      end

      it 'should raise an exception' do
        expect { repository.create(record_class: record_class) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with record_class: a class' do
      let(:record_class) { Class.new }
      let(:error_message) do
        'record class must be an ActiveRecord model'
      end

      it 'should raise an exception' do
        expect { repository.create(record_class: record_class) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with record class: an ActiveRecord model class' do
      let(:record_class) { Tome }

      it { expect(create_collection).to be_a Cuprum::Rails::Collection }

      it { expect(create_collection.record_class).to be record_class }

      it 'should add the collection to the repository' do
        collection = create_collection

        expect(repository['tomes']).to be collection
      end

      describe 'with options' do
        let(:options) do
          super().merge(member_name: 'grimoire')
        end

        it { expect(create_collection.member_name).to be == 'grimoire' }
      end

      context 'when a collection already exists' do
        let(:existing_collection) do
          Cuprum::Rails::Collection.new(record_class: Tome)
        end
        let(:error_class) do
          Cuprum::Collections::Repository::DuplicateCollectionError
        end
        let(:error_message) do
          "collection #{existing_collection.collection_name} already exists"
        end

        before(:example) do
          repository.add(existing_collection)
        end

        it 'should raise an exception' do
          expect { create_collection }
            .to raise_error(error_class, error_message)
        end
      end
    end
  end

  describe '#find_or_create' do
    let(:record_class) { Tome }
    let(:options)      { {} }

    def find_or_create_collection
      repository.find_or_create(
        record_class: record_class,
        **options
      )
    end

    it 'should define the method' do
      expect(repository)
        .to respond_to(:find_or_create)
        .with_keywords(:record_class)
        .and_any_keywords
    end

    describe 'with record_class: nil' do
      let(:record_class) { nil }
      let(:error_message) do
        'record class must be an ActiveRecord model'
      end

      it 'should raise an exception' do
        expect { repository.find_or_create(record_class: record_class) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with record_class: an object' do
      let(:record_class) { Object.new.freeze }
      let(:error_message) do
        'record class must be an ActiveRecord model'
      end

      it 'should raise an exception' do
        expect { repository.find_or_create(record_class: record_class) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with record_class: a class' do
      let(:record_class) { Class.new }
      let(:error_message) do
        'record class must be an ActiveRecord model'
      end

      it 'should raise an exception' do
        expect { repository.find_or_create(record_class: record_class) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with record class: an ActiveRecord model class' do
      let(:record_class) { Tome }

      it { expect(find_or_create_collection).to be_a Cuprum::Rails::Collection }

      it { expect(find_or_create_collection.record_class).to be record_class }

      it 'should add the collection to the repository' do
        collection = find_or_create_collection

        expect(repository['tomes']).to be collection
      end

      describe 'with options' do
        let(:options) do
          super().merge(member_name: 'grimoire')
        end

        it { expect(find_or_create_collection.member_name).to be == 'grimoire' }
      end

      context 'when a collection already exists' do
        let(:existing_options) { { record_class: Tome } }
        let(:existing_collection) do
          Cuprum::Rails::Collection.new(**existing_options)
        end

        before(:example) do
          repository.add(existing_collection)
        end

        it { expect(find_or_create_collection).to be existing_collection }

        context 'when the existing collection has another record class' do
          let(:existing_options) do
            super().merge(collection_name: 'tomes', record_class: Book)
          end
          let(:error_class) do
            Cuprum::Collections::Repository::DuplicateCollectionError
          end
          let(:error_message) do
            "collection #{existing_collection.collection_name} already exists"
          end

          it 'should raise an exception' do
            expect { find_or_create_collection }
              .to raise_error(error_class, error_message)
          end
        end

        context 'when the existing collection has non-matching options' do
          let(:existing_options) do
            super().merge(key: 'other value')
          end
          let(:error_class) do
            Cuprum::Collections::Repository::DuplicateCollectionError
          end
          let(:error_message) do
            "collection #{existing_collection.collection_name} already exists"
          end

          it 'should raise an exception' do
            expect { find_or_create_collection }
              .to raise_error(error_class, error_message)
          end
        end
      end
    end
  end
end
