# frozen_string_literal: true

require 'cuprum/rails/constraints/parameters_contract'

require 'support/examples/constraint_examples'

RSpec.describe Cuprum::Rails::Constraints::ParametersContract do
  include Spec::Support::Examples::ConstraintExamples

  subject(:contract) { described_class.new(**options, &block) }

  let(:block)   { nil }
  let(:options) { {} }

  describe '#match' do
    let(:match_method) { :match }

    describe 'with nil' do
      let(:actual) { nil }
      let(:expected_errors) do
        {
          data: {
            allow_empty: true,
            required:    true,
            type:        Hash
          },
          type: Stannum::Constraints::Type::TYPE
        }
      end
      let(:expected_messages) do
        expected_errors.merge(message: 'is not a Hash')
      end

      include_examples 'should not match the constraint'
    end

    describe 'with an Object' do
      let(:actual) { Object.new.freeze }
      let(:expected_errors) do
        {
          data: {
            allow_empty: true,
            required:    true,
            type:        Hash
          },
          type: Stannum::Constraints::Type::TYPE
        }
      end
      let(:expected_messages) do
        expected_errors.merge(message: 'is not a Hash')
      end

      include_examples 'should not match the constraint'
    end

    describe 'with an empty Hash' do
      let(:actual) { {} }

      include_examples 'should match the constraint'
    end

    context 'when the contract has many constraints' do
      let(:block) do
        lambda do
          key 'ok',     Stannum::Constraints::Boolean.new
          key 'status', Stannum::Constraints::Types::IntegerType.new
        end
      end

      describe 'with an empty Hash' do
        let(:actual) { {} }
        let(:expected_errors) do
          [
            {
              path: %w[ok],
              type: Stannum::Constraints::Boolean::TYPE
            },
            {
              data: {
                required: true,
                type:     Integer
              },
              path: %w[status],
              type: Stannum::Constraints::Type::TYPE
            }
          ]
        end

        include_examples 'should not match the constraint'
      end

      describe 'with an non-matching Hash with String keys' do
        let(:actual) { { 'status' => 200 } }
        let(:expected_errors) do
          [
            {
              path: %w[ok],
              type: Stannum::Constraints::Boolean::TYPE
            }
          ]
        end

        include_examples 'should not match the constraint'
      end

      describe 'with a non-matching Hash with Symbol keys' do
        let(:actual) { { status: 200 } }
        let(:expected_errors) do
          [
            {
              path: %w[ok],
              type: Stannum::Constraints::Boolean::TYPE
            }
          ]
        end

        include_examples 'should not match the constraint'
      end

      describe 'with an matching Hash with String keys' do
        let(:actual) { { 'ok' => true, 'status' => 200 } }

        include_examples 'should match the constraint'
      end

      describe 'with a matching Hash with Symbol keys' do
        let(:actual) { { ok: true, status: 200 } }

        include_examples 'should match the constraint'
      end
    end
  end
end
