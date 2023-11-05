# frozen_string_literal: true

require 'rspec/sleeping_king_studios/contract'

require 'cuprum/rails/rspec/contracts'

module Cuprum::Rails::RSpec::Contracts
  # Namespace for RSpec contracts for Routes objects.
  module RoutesContracts
    # Contract asserting that the given collection route helper is defined.
    module ShouldDefineCollectionRouteContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, constructor_keywords: [])
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param action_name [String, Symbol] the name of the route action.
      #   @param path [String] the expected path for the route helper.
      #   @param options [Hash] additional options for the contract.
      #
      #   @option options wildcards [Hash{String=>String}] the required
      #     wildcards for generating the route.
      contract do |action_name:, path:, **options|
        options[:wildcards] = options.fetch(:wildcards, {}).stringify_keys
        expected_wildcards  =
          path.split('/').select { |str| str.start_with?(':') }

        describe "##{action_name}_path" do
          let(:method_name) { "#{action_name}_path" }
          let(:wildcards)   { options[:wildcards] }
          let(:expected) do
            expected_wildcards.reduce(path) do |resolved, key|
              resolved.sub(key, resolve_wildcard(key))
            end
          end
          let(:error_class) do
            Cuprum::Rails::Routes::MissingWildcardError
          end
          let(:error_message) do
            "missing wildcard #{expected_wildcards.first}"
          end

          def resolve_wildcard(key)
            key   = key.sub(/\A:/, '')
            value =
              wildcards.fetch(key) { wildcards.fetch(key.sub(/_id\z/, '')) }

            return value.to_s unless value.class.respond_to?(:primary_key)

            primary_key = value.class.primary_key

            value[primary_key].to_s
          end

          it 'should define the helper method' do
            expect(subject)
              .to respond_to(method_name)
              .with(0).arguments
              .and_any_keywords
          end

          if expected_wildcards.empty?
            it { expect(subject.send(method_name)).to be == expected }
          else
            it 'should raise an exception' do
              expect { subject.send(method_name) }
                .to raise_error(error_class, error_message)
            end

            expected_wildcards.each do |key|
              describe "with wildcards: missing #{key}" do
                let(:wildcards) do
                  wildcard = key[1..]

                  super().except(wildcard, wildcard[...-3])
                end
                let(:error_message) { "missing wildcard #{key}" }

                it 'should raise an exception' do
                  expect { subject.send(method_name, **wildcards) }
                    .to raise_error(error_class, error_message)
                end
              end

              context "when the routes defines wildcards: missing #{key}" do
                let(:wildcards) do
                  wildcard = key[1..]

                  super().except(wildcard, wildcard[...-3])
                end
                let(:error_message) { "missing wildcard #{key}" }

                it 'should raise an exception' do
                  expect { subject.with_wildcards(wildcards).send(method_name) }
                    .to raise_error(error_class, error_message)
                end
              end
            end

            describe 'with wildcards: matching wildcards' do
              it 'should generate the path' do
                expect(subject.send(method_name, **wildcards)).to be == expected
              end
            end

            context 'when the routes defines wildcards: matching wildcards' do
              it 'should generate the path' do
                expect(subject.with_wildcards(wildcards).send(method_name))
                  .to be == expected
              end

              describe 'with wildcards: value' do
                let(:other_wildcards) do
                  expected_wildcards.each.with_index.to_h
                end

                it 'should generate the path' do
                  expect(
                    subject
                      .with_wildcards(other_wildcards)
                      .send(method_name, **wildcards)
                  )
                    .to be == expected
                end
              end
            end
          end

          describe 'with wildcards: extra wildcards' do
            let(:wildcards) { super().merge('other_id' => 'value') }

            it 'should generate the path' do
              expect(subject.send(method_name, **wildcards)).to be == expected
            end
          end

          context 'when the routes defines wildcards: extra wildcards' do
            let(:wildcards) { super().merge('other_id' => 'value') }

            it 'should generate the path' do
              expect(subject.with_wildcards(wildcards).send(method_name))
                .to be == expected
            end
          end
        end
      end
    end

    # Contract asserting that the given member route helper is defined.
    module ShouldDefineMemberRouteContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, constructor_keywords: [])
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param action_name [String, Symbol] the name of the route action.
      #   @param path [String] the expected path for the route helper.
      #   @param options [Hash] additional options for the contract.
      #
      #   @option options wildcards [Hash{String=>String}] the required
      #     wildcards for generating the route.
      contract do |action_name:, path:, **options|
        options[:wildcards] = options.fetch(:wildcards, {}).stringify_keys
        expected_wildcards  =
          path.split('/').select { |str| str.start_with?(':') && str != ':id' }

        describe "##{action_name}_path" do
          let(:configured_wildcards) { options[:wildcards] }
          let(:method_name)          { "#{action_name}_path" }
          let(:wildcards)            { options[:wildcards] }
          let(:entity_value)         { options[:wildcards].fetch('id') }
          let(:expected) do
            [':id', *expected_wildcards].reduce(path) do |resolved, key|
              resolved.sub(key, resolve_wildcard(key))
            end
          end
          let(:error_class) do
            Cuprum::Rails::Routes::MissingWildcardError
          end
          let(:error_message) do
            "missing wildcard #{expected_wildcards.first}"
          end

          def resolve_wildcard(key)
            key   = key.sub(/\A:/, '')
            value =
              configured_wildcards
                .stringify_keys
                .fetch(key) { wildcards.fetch(key.sub(/_id\z/, '')) }

            return value.to_s unless value.class.respond_to?(:primary_key)

            primary_key = value.class.primary_key

            value[primary_key].to_s
          end

          it 'should define the helper method' do
            expect(subject)
              .to respond_to(method_name)
              .with(0..1).arguments
              .and_any_keywords
          end

          if expected_wildcards.empty?
            it 'should raise an exception' do
              expect { subject.send(method_name) }
                .to raise_error(error_class, 'missing wildcard :id')
            end

            describe 'with entity: value' do
              it 'should generate the path' do
                expect(subject.send(method_name, entity_value))
                  .to be == expected
              end
            end

            describe 'with wildcards: matching wildcards' do
              it 'should generate the path' do
                expect(subject.send(method_name, **wildcards))
                  .to be == expected
              end

              describe 'with entity: value' do
                let(:other_wildcards) do
                  [':id', expected_wildcards].each.with_index.to_h
                end

                it 'should generate the path' do
                  expect(
                    subject.send(method_name, entity_value, **other_wildcards)
                  )
                    .to be == expected
                end
              end
            end

            context 'when the routes defines wildcards: matching wildcards' do
              it 'should generate the path' do
                expect(subject.with_wildcards(**wildcards).send(method_name))
                  .to be == expected
              end

              describe 'with entity: value' do
                let(:other_wildcards) do
                  [':id', expected_wildcards].each.with_index.to_h
                end

                it 'should generate the path' do
                  expect(
                    subject
                      .with_wildcards(**other_wildcards)
                      .send(method_name, entity_value)
                  )
                    .to be == expected
                end
              end
            end
          else
            it 'should raise an exception' do
              expect { subject.send(method_name) }
                .to raise_error(error_class, error_message)
            end

            expected_wildcards.each do |key|
              describe "with wildcards: missing #{key}" do
                let(:wildcards) do
                  wildcard = key[1..]

                  super().except(wildcard, wildcard[...-3])
                end
                let(:error_message) { "missing wildcard #{key}" }

                it 'should raise an exception' do
                  expect { subject.send(method_name, **wildcards) }
                    .to raise_error(error_class, error_message)
                end
              end

              context "when the routes defines wildcards: missing #{key}" do
                let(:wildcards) do
                  wildcard = key[1..]

                  super().except(wildcard, wildcard[...-3])
                end
                let(:error_message) { "missing wildcard #{key}" }

                it 'should raise an exception' do
                  expect { subject.with_wildcards(wildcards).send(method_name) }
                    .to raise_error(error_class, error_message)
                end
              end
            end

            describe 'with entity: value' do
              it 'should raise an exception' do
                expect { subject.send(method_name) }
                  .to raise_error(error_class, error_message)
              end

              describe 'with wildcards: matching wildcards' do
                let(:wildcards) { super().except('id') }

                it 'should generate the path' do
                  expect(subject.send(method_name, entity_value, **wildcards))
                    .to be == expected
                end
              end

              context 'when the routes defines wildcards: matching wildcards' do
                let(:wildcards) { super().except('id') }

                it 'should generate the path' do
                  expect(
                    subject
                      .with_wildcards(wildcards)
                      .send(method_name, entity_value)
                  )
                    .to be == expected
                end
              end
            end

            describe 'with wildcards: matching wildcards' do
              it 'should generate the path' do
                expect(subject.send(method_name, **wildcards))
                  .to be == expected
              end
            end

            context 'when the routes defines wildcards: matching wildcards' do
              it 'should generate the path' do
                expect(subject.with_wildcards(wildcards).send(method_name))
                  .to be == expected
              end
            end
          end

          describe 'with wildcards: extra wildcards' do
            let(:wildcards) { super().merge('other_id' => 'value') }

            it 'should generate the path' do
              expect(subject.send(method_name, **wildcards)).to be == expected
            end
          end

          context 'when the routes defines wildcards: extra wildcards' do
            let(:wildcards) { super().merge('other_id' => 'value') }

            it 'should generate the path' do
              expect(subject.with_wildcards(wildcards).send(method_name))
                .to be == expected
            end
          end
        end
      end
    end
  end
end
