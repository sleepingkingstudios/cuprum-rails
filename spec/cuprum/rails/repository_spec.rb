# frozen_string_literal: true

require 'cuprum/collections/basic/repository'
require 'cuprum/collections/rspec/contracts/repository_contracts'

require 'cuprum/rails/repository'

require 'support/book'
require 'support/tome'

RSpec.describe Cuprum::Rails::Repository do
  include Cuprum::Collections::RSpec::Contracts::RepositoryContracts

  subject(:repository) { described_class.new }

  shared_context 'when the repository has many collections' do
    let(:books_collection) do
      Cuprum::Rails::Collection.new(entity_class: Book)
    end
    let(:magazines_collection) do
      Cuprum::Rails::Collection.new(
        name:           'magazines',
        qualified_name: 'magazines',
        entity_class:   Spec::Magazine
      )
    end
    let(:periodicals_collection) do
      Cuprum::Rails::Collection.new(
        name:         'periodicals',
        entity_class: Spec::Periodical
      )
    end
    let(:collections) do
      {
        'books'            => books_collection,
        'magazines'        => magazines_collection,
        'spec/periodicals' => periodicals_collection
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
    Cuprum::Rails::Collection.new(entity_class: Tome)
  end

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(0).arguments }
  end

  example_class 'Grimoire',         'Book'

  example_class 'Spec::ScopedBook', 'Book'

  include_contract 'should be a repository',
    collection_class: Cuprum::Rails::Collection

  describe '#add' do
    describe 'with an invalid collection' do
      let(:error_class) do
        described_class::InvalidCollectionError
      end
      let(:error_message) do
        "#{collection.inspect} is not a valid collection"
      end
      let(:collection) do
        Struct.new(:name).new
      end

      it 'should raise an exception' do
        expect { repository.add(collection) }
          .to raise_error(error_class, error_message)
      end
    end
  end
end
