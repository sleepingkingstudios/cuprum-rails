# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/command_examples'
require 'cuprum/collections/rspec/fixtures'

require 'cuprum/rails/records/collection'

require 'support/book'
require 'support/tome'
require 'support/examples/records'

module Spec::Support::Examples::Records
  module CommandExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_context 'with a collection with a custom primary key' do
      let(:entity_class)     { Tome }
      let(:primary_key_name) { 'uuid' }
      let(:primary_key_type) { String }
      let(:mapped_data) do
        data.map do |item|
          item.dup.tap do |hsh|
            value = hsh.delete('id').to_s.rjust(12, '0')

            hsh['uuid'] = "00000000-0000-0000-0000-#{value}"
          end
        end
      end
      let(:invalid_primary_key_value) { '00000000-0000-0000-0000-000000000100' }
      let(:valid_primary_key_value)   { '00000000-0000-0000-0000-000000000000' }
      let(:invalid_primary_key_values) do
        %w[
          00000000-0000-0000-0000-000000000100
          00000000-0000-0000-0000-000000000101
          00000000-0000-0000-0000-000000000102
        ]
      end
      let(:valid_primary_key_values) do
        %w[
          00000000-0000-0000-0000-000000000000
          00000000-0000-0000-0000-000000000001
          00000000-0000-0000-0000-000000000002
        ]
      end
    end

    deferred_context 'with parameters for a records command' do
      let(:entity_class) { Book }
      let(:record_class) { entity_class }
      let(:collection) do
        Cuprum::Rails::Records::Collection.new(
          entity_class:,
          **collection_options
        )
      end
      let(:collection_options)  { {} }
      let(:data)                { [] }
      let(:mapped_data)         { defined?(super()) ? super() : data }
      let(:fixtures_data) do
        Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.dup
      end

      before(:example) do
        mapped_data.each { |attributes| record_class.create!(attributes) }
      end
    end

    deferred_examples 'should implement the Records::Command methods' do
      include Cuprum::Collections::RSpec::Deferred::CommandExamples

      include_deferred 'should implement the CollectionCommand methods'

      describe '.new' do
        it 'should define the constructor' do
          expect(described_class)
            .to respond_to(:new)
            .with(0).arguments
            .and_keywords(:collection)
        end
      end

      describe '#record_class' do
        include_examples 'should define reader',
          :record_class,
          -> { collection.entity_class }

        wrap_deferred 'with a collection with a custom primary key' do
          it { expect(command.record_class).to be == collection.entity_class }
        end
      end
    end

    deferred_examples 'should validate the entity' do
      describe 'with an invalid entity value' do
        let(:entity) { Object.new.freeze }
        let(:expected_error) do
          Cuprum::Errors::InvalidParameters.new(
            command_class: command.class,
            failures:      [
              tools.assertions.error_message_for(
                'sleeping_king_studios.tools.assertions.instance_of',
                as:       :entity,
                expected: entity_class
              )
            ]
          )
        end

        it 'should return a failing result with InvalidParameters error' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end
  end
end
