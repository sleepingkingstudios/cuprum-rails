# frozen_string_literal: true

require 'cuprum/collections/queries'
require 'cuprum/collections/rspec/contracts/scopes/criteria_contracts'

require 'cuprum/rails/rspec/contracts/scope_contracts'
require 'cuprum/rails/scopes/criteria_scope'

RSpec.describe Cuprum::Rails::Scopes::CriteriaScope do
  include Cuprum::Collections::RSpec::Contracts::Scopes::CriteriaContracts
  include Cuprum::Rails::RSpec::Contracts::ScopeContracts

  subject(:scope) do
    described_class.new(criteria:, **constructor_options)
  end

  let(:criteria)            { [] }
  let(:native_query)        { Book.all }
  let(:data)                { [] }
  let(:constructor_options) { {} }

  def filtered_data
    subject
      .call(native_query:)
      .map do |record|
        record
          .attributes
          .merge('published_at' => record.published_at.strftime('%Y-%m-%d'))
      end
  end

  describe '::Builder' do
    subject(:builder) { described_class.instance }

    let(:described_class) { super()::Builder }
    let(:operators)       { Cuprum::Collections::Queries::Operators }

    describe '.instance' do
      it { expect(described_class).to define_reader(:instance) }

      it { expect(described_class.instance).to be_a described_class }

      it { expect(described_class.instance).to be builder }
    end

    describe '#call' do
      it 'should define the method' do
        expect(builder)
          .to respond_to(:call)
          .with(0).arguments
          .and_keywords(:criteria)
      end

      describe 'with criteria: an empty Array' do
        let(:criteria) { [] }
        let(:expected) { '' }

        it { expect(builder.call(criteria:)).to be == expected }
      end

      describe 'with an equals criterion with value: nil' do
        let(:criteria) do
          [
            [
              'title',
              operators::EQUAL,
              nil
            ]
          ]
        end
        let(:expected) { 'title IS NULL' }

        it { expect(builder.call(criteria:)).to be == expected }
      end

      describe 'with an equals criterion with value: an Integer' do
        let(:criteria) do
          [
            [
              'copies_sold',
              operators::EQUAL,
              10_000
            ]
          ]
        end
        let(:expected) { 'copies_sold = 10000' }

        it { expect(builder.call(criteria:)).to be == expected }
      end

      describe 'with an equals criterion with value: a String' do
        let(:criteria) do
          [
            [
              'title',
              operators::EQUAL,
              'Gideon the Ninth'
            ]
          ]
        end
        let(:expected) { "title = 'Gideon the Ninth'" }

        it { expect(builder.call(criteria:)).to be == expected }
      end

      describe 'with a greater than criterion' do
        let(:criteria) do
          [
            [
              'copies_sold',
              operators::GREATER_THAN,
              10_000
            ]
          ]
        end
        let(:expected) { 'copies_sold > 10000' }

        it { expect(builder.call(criteria:)).to be == expected }
      end

      describe 'with a greater than or equal to criterion' do
        let(:criteria) do
          [
            [
              'copies_sold',
              operators::GREATER_THAN_OR_EQUAL_TO,
              10_000
            ]
          ]
        end
        let(:expected) { 'copies_sold >= 10000' }

        it { expect(builder.call(criteria:)).to be == expected }
      end

      describe 'with a less than criterion' do
        let(:criteria) do
          [
            [
              'copies_sold',
              operators::LESS_THAN,
              10_000
            ]
          ]
        end
        let(:expected) { 'copies_sold < 10000' }

        it { expect(builder.call(criteria:)).to be == expected }
      end

      describe 'with a less than or equal to criterion' do
        let(:criteria) do
          [
            [
              'copies_sold',
              operators::LESS_THAN_OR_EQUAL_TO,
              10_000
            ]
          ]
        end
        let(:expected) { 'copies_sold <= 10000' }

        it { expect(builder.call(criteria:)).to be == expected }
      end

      describe 'with a not equals criterion with value: nil' do
        let(:criteria) do
          [
            [
              'title',
              operators::NOT_EQUAL,
              nil
            ]
          ]
        end
        let(:expected) { 'title IS NOT NULL' }

        it { expect(builder.call(criteria:)).to be == expected }
      end

      describe 'with a not equals criterion with value: an Integer' do
        let(:criteria) do
          [
            [
              'copies_sold',
              operators::NOT_EQUAL,
              10_000
            ]
          ]
        end
        let(:expected) do
          '(copies_sold != 10000 OR copies_sold IS NULL)'
        end

        it { expect(builder.call(criteria:)).to be == expected }
      end

      describe 'with a not equals criterion with value: a String' do
        let(:criteria) do
          [
            [
              'title',
              operators::NOT_EQUAL,
              'Gideon the Ninth'
            ]
          ]
        end
        let(:expected) do
          "(title != 'Gideon the Ninth' OR title IS NULL)"
        end

        it { expect(builder.call(criteria:)).to be == expected }
      end

      describe 'with a not one of criterion' do
        let(:criteria) do
          [
            [
              'title',
              operators::NOT_ONE_OF,
              [
                'Gideon the Ninth',
                'Harrow the Ninth'
              ]
            ]
          ]
        end
        let(:expected) do
          "(title NOT IN ('Gideon the Ninth','Harrow the Ninth') OR title " \
            'IS NULL)'
        end

        it { expect(builder.call(criteria:)).to be == expected }
      end

      describe 'with a one of criterion' do
        let(:criteria) do
          [
            [
              'title',
              operators::ONE_OF,
              [
                'Gideon the Ninth',
                'Harrow the Ninth'
              ]
            ]
          ]
        end
        let(:expected) do
          "title IN ('Gideon the Ninth','Harrow the Ninth')"
        end

        it { expect(builder.call(criteria:)).to be == expected }
      end

      describe 'with an invalid criterion' do
        let(:criteria) do
          [
            [
              'title',
              'random',
              [
                'Gideon the Ninth',
                'Harrow the Ninth'
              ]
            ]
          ]
        end
        let(:error_class) do
          Cuprum::Collections::Queries::UnknownOperatorException
        end
        let(:error_message) do
          'unknown operator "random"'
        end

        it 'should raise an exception' do
          expect { builder.call(criteria:) }
            .to raise_error error_class, error_message
        end
      end

      describe 'with multiple criteria' do
        let(:criteria) do
          [
            [
              'author',
              operators::EQUAL,
              'Tamsyn Muir'
            ],
            [
              'copies_sold',
              operators::GREATER_THAN,
              10_000
            ]
          ]
        end
        let(:expected) { "author = 'Tamsyn Muir' AND copies_sold > 10000" }

        it { expect(builder.call(criteria:)).to be == expected }
      end
    end
  end

  include_contract 'should be a criteria scope'

  include_contract 'should be a rails scope'

  describe '#build_relation' do
    let(:record_class) { Book }

    def filtered_data
      scope
        .build_relation(record_class:)
        .map do |record|
          record
            .attributes
            .merge('published_at' => record.published_at.strftime('%Y-%m-%d'))
        end
    end

    include_contract 'should filter data by criteria'
  end
end
