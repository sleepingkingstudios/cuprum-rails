# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/query_contracts'

require 'cuprum/rails/query'
require 'cuprum/rails/query_builder'

require 'support/book'

RSpec.xdescribe Cuprum::Rails::QueryBuilder do
  include Cuprum::Collections::RSpec::Contracts::QueryContracts

  subject(:builder) { described_class.new(base_query) }

  let(:base_query) { Cuprum::Rails::Query.new(Book) }

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(1).argument }
  end

  # include_contract 'should be a query builder'

  describe '#call' do
    let(:books_attributes) do
      [
        {
          title:  'Gideon the Ninth',
          author: 'Tamsyn Muir',
          series: 'The Locked Tomb'
        }
      ]
    end
    let(:books) do
      books_attributes.map { |attributes| Book.new(attributes) }
    end

    before(:example) { books.each(&:save!) }

    describe 'with where: a block' do
      let(:block) do
        -> { { author: 'Nnedi Okorafor', series: 'Binti' } }
      end
      let(:query)        { builder.call(where: block) }
      let(:native_query) { query.send(:native_query) }

      context 'when there is no matching data' do
        it { expect(native_query.size).to be 0 }
      end

      context 'when there is partially matching data' do
        let(:books_attributes) do
          super() + [
            {
              title:  'Akata Witch',
              author: 'Nnedi Okorafor',
              series: nil
            }
          ]
        end

        it { expect(native_query.size).to be 0 }
      end

      context 'when there is matching data' do
        let(:books_attributes) do
          super() + [
            {
              title:  'Akata Witch',
              author: 'Nnedi Okorafor',
              series: nil
            },
            {
              title:  'Binti',
              author: 'Nnedi Okorafor',
              series: 'Binti'
            },
            {
              title:  'Binti: Home',
              author: 'Nnedi Okorafor',
              series: 'Binti'
            },
            {
              title:  'Binti: The Night Masquerade',
              author: 'Nnedi Okorafor',
              series: 'Binti'
            }
          ]
        end
        let(:expected) do
          ['Binti', 'Binti: Home', 'Binti: The Night Masquerade']
        end

        it { expect(native_query.size).to be 3 }

        it { expect(native_query.pluck(:title)).to match_array(expected) }
      end
    end
  end
end
