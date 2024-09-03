# frozen_string_literal: true

require 'rspec/sleeping_king_studios/contract'

require 'cuprum/rails/rspec/contracts'

require 'support/book'
require 'support/tome'

module Cuprum::Rails::RSpec::Contracts
  # Namespace for RSpec command contracts.
  module CommandContracts
    # Contract validating the behavior of a Rails command implementation.
    module ShouldBeARailsCommandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        describe '.subclass' do
          let(:subclass) { described_class.subclass }
          let(:constructor_options) do
            hsh = {
              record_class: Book,
              optional_key: 'optional value'
            }

            if described_class < Cuprum::Collections::Commands::QueryCommand
              hsh[:query] = query
            end

            hsh
          end

          it 'should define the class method' do
            expect(described_class)
              .to respond_to(:subclass)
              .with(0).arguments
              .and_any_keywords
          end

          it { expect(subclass).to be_a Class }

          it { expect(subclass).to be < described_class }

          it 'should define the constructor' do
            expect(subclass)
              .to respond_to(:new)
              .with(0).arguments
              .and_any_keywords
          end

          it 'should return the record class' do
            expect(subclass.new(**constructor_options).record_class)
              .to be record_class
          end

          it 'should return the options' do
            expect(subclass.new(**constructor_options).options)
              .to be == { optional_key: 'optional value' }
          end

          describe 'with options' do
            let(:default_options) do
              {
                record_class: Book,
                custom_key:   'custom value'
              }
            end
            let(:constructor_options) do
              hsh = { optional_key: 'optional value' }

              if described_class < Cuprum::Collections::Commands::QueryCommand
                hsh[:query] = query
              end

              hsh
            end
            let(:subclass) { described_class.subclass(**default_options) }

            it { expect(subclass).to be_a Class }

            it { expect(subclass).to be < described_class }

            it 'should define the constructor' do
              expect(subclass)
                .to respond_to(:new)
                .with(0).arguments
                .and_any_keywords
            end

            it 'should return the record class' do
              expect(subclass.new(**constructor_options).record_class)
                .to be record_class
            end

            it 'should return the options' do
              expect(subclass.new(**constructor_options).options)
                .to be == {
                  custom_key:   'custom value',
                  optional_key: 'optional value'
                }
            end
          end
        end

        describe '#collection_name' do
          let(:expected) { record_class.name.underscore.pluralize }

          include_examples 'should define reader',
            :collection_name,
            -> { be == expected }

          context 'when initialized with collection_name: string' do
            let(:collection_name) { 'books' }
            let(:constructor_options) do
              super().merge(collection_name:)
            end

            it { expect(command.collection_name).to be == collection_name }
          end

          context 'when initialized with collection_name: symbol' do
            let(:collection_name) { :books }
            let(:constructor_options) do
              super().merge(collection_name:)
            end

            it { expect(command.collection_name).to be == collection_name.to_s }
          end
        end

        describe '#member_name' do
          def tools
            SleepingKingStudios::Tools::Toolbelt.instance
          end

          include_examples 'should have reader',
            :member_name,
            -> { record_class.name.underscore }

          context 'when initialized with collection_name: value' do
            let(:collection_name) { :books }

            it 'should return the singular collection name' do
              expect(command.member_name)
                .to be == tools.str.singularize(collection_name.to_s)
            end
          end

          context 'when initialized with member_name: string' do
            let(:member_name) { 'tome' }
            let(:constructor_options) do
              super().merge(member_name:)
            end

            it 'should return the singular collection name' do
              expect(command.member_name).to be member_name
            end
          end

          context 'when initialized with member_name: symbol' do
            let(:member_name) { :tome }
            let(:constructor_options) do
              super().merge(member_name:)
            end

            it 'should return the singular collection name' do
              expect(command.member_name).to be == member_name.to_s
            end
          end
        end

        describe '#options' do
          let(:expected_options) do
            defined?(super()) ? super() : constructor_options
          end

          include_examples 'should define reader',
            :options,
            -> { be == expected_options }

          context 'when initialized with options' do
            let(:constructor_options) { super().merge({ key: 'value' }) }
            let(:expected_options)    { super().merge({ key: 'value' }) }

            it { expect(command.options).to be == expected_options }
          end
        end

        describe '#primary_key_name' do
          include_examples 'should define reader', :primary_key_name, 'id'

          context 'with a record class with custom primary key' do
            let(:record_class) { Tome }

            include_examples 'should define reader', :primary_key_name, 'uuid'
          end
        end

        describe '#primary_key_type' do
          include_examples 'should define reader', :primary_key_type, Integer

          context 'with a record class with custom primary key' do
            let(:record_class) { Tome }

            include_examples 'should define reader', :primary_key_type, String
          end
        end

        describe '#record_class' do
          include_examples 'should define reader',
            :record_class,
            -> { record_class }
        end

        describe '#validate_entity' do
          let(:expected_error) do
            type     = record_class
            contract = Stannum::Contracts::ParametersContract.new do
              keyword :entity, type
            end
            errors = contract.errors_for(
              {
                arguments: [],
                block:     nil,
                keywords:  { entity: nil }
              }
            )

            Cuprum::Collections::Errors::InvalidParameters.new(
              command:,
              errors:
            )
          end

          it 'should define the private method' do
            expect(command)
              .to respond_to(:validate_entity, true)
              .with(1).argument
          end

          describe 'with nil' do
            it 'should return a failing result' do
              expect(command.send(:validate_entity, nil))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'with an Object' do
            it 'should return a failing result' do
              expect(command.send(:validate_entity, Object.new.freeze))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'with an invalid record instance' do
            it 'should return a failing result' do
              expect(command.send(:validate_entity, Tome.new))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'with a valid record instance' do
            it 'should not return a result' do
              expect(command.send(:validate_entity, Book.new))
                .not_to be_a_result
            end
          end
        end

        describe '#validate_primary_key' do
          let(:primary_key_type) { Integer }
          let(:expected_error) do
            type     = primary_key_type
            contract = Stannum::Contracts::ParametersContract.new do
              keyword :primary_key, type
            end
            errors = contract.errors_for(
              {
                arguments: [],
                block:     nil,
                keywords:  { primary_key: nil }
              }
            )

            Cuprum::Collections::Errors::InvalidParameters.new(
              command:,
              errors:
            )
          end

          it 'should define the private method' do
            expect(command)
              .to respond_to(:validate_primary_key, true)
              .with(1).argument
          end

          describe 'with nil' do
            it 'should return a failing result' do
              expect(command.send(:validate_primary_key, nil))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'with an Object' do
            it 'should return a failing result' do
              expect(command.send(:validate_primary_key, Object.new.freeze))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'with a String' do
            it 'should return a failing result' do
              expect(command.send(:validate_primary_key, '12345'))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'with an Integer' do
            it 'should not return a result' do
              expect(command.send(:validate_primary_key, 12_345))
                .not_to be_a_result
            end
          end

          context 'with a record class with custom primary key' do
            let(:record_class)     { Tome }
            let(:primary_key_type) { String }

            describe 'with an Integer' do
              it 'should return a failing result' do
                expect(command.send(:validate_primary_key, 12_345))
                  .to be_a_failing_result
                  .with_error(expected_error)
              end
            end

            describe 'with a String' do
              it 'should not return a result' do
                expect(command.send(:validate_primary_key, '12345'))
                  .not_to be_a_result
              end
            end
          end
        end

        describe '#validate_primary_keys' do
          let(:primary_keys)     { nil }
          let(:primary_key_type) { Integer }
          let(:expected_error) do
            type     = primary_key_type
            contract = Stannum::Contracts::ParametersContract.new do
              keyword :primary_keys,
                Stannum::Constraints::Types::ArrayType.new(item_type: type)
            end
            errors = contract.errors_for(
              {
                arguments: [],
                block:     nil,
                keywords:  { primary_keys: }
              }
            )

            Cuprum::Collections::Errors::InvalidParameters.new(
              command:,
              errors:
            )
          end

          it 'should define the private method' do
            expect(command)
              .to respond_to(:validate_primary_keys, true)
              .with(1).argument
          end

          describe 'with nil' do
            it 'should return a failing result' do
              expect(command.send(:validate_primary_keys, nil))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'with an Object' do
            it 'should return a failing result' do
              expect(command.send(:validate_primary_keys, Object.new.freeze))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'with a String' do
            it 'should return a failing result' do
              expect(command.send(:validate_primary_keys, '12345'))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'with an Integer' do
            it 'should return a failing result' do
              expect(command.send(:validate_primary_keys, 12_345))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'with an empty Array' do
            it 'should not return a result' do
              expect(command.send(:validate_primary_keys, []))
                .not_to be_a_result
            end
          end

          describe 'with an Array with nil values' do
            let(:primary_keys) { Array.new(3, nil) }

            it 'should return a failing result' do
              expect(command.send(:validate_primary_keys, primary_keys))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'with an Array with Object values' do
            let(:primary_keys) { Array.new(3) { Object.new.freeze } }

            it 'should return a failing result' do
              expect(command.send(:validate_primary_keys, primary_keys))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'with an Array with String values' do
            let(:primary_keys) { %w[ichi ni san] }

            it 'should return a failing result' do
              expect(command.send(:validate_primary_keys, primary_keys))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'with an Array with Integer values' do
            it 'should not return a result' do
              expect(command.send(:validate_primary_keys, [0, 1, 2]))
                .not_to be_a_result
            end
          end

          context 'with a record class with custom primary key' do
            let(:record_class)     { Tome }
            let(:primary_key_type) { String }

            describe 'with an Array with String values' do
              let(:primary_keys) { %w[ichi ni san] }

              it 'should not return a result' do
                expect(command.send(:validate_primary_keys, primary_keys))
                  .not_to be_a_result
              end
            end

            describe 'with an Array with Integer values' do
              let(:primary_keys) { [0, 1, 2] }

              it 'should return a failing result' do
                expect(command.send(:validate_primary_keys, primary_keys))
                  .to be_a_failing_result
                  .with_error(expected_error)
              end
            end
          end
        end
      end
    end
  end
end
