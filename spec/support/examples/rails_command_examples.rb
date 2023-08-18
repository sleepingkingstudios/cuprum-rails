# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'cuprum/collections/rspec/fixtures'

require 'cuprum/rails/query'

require 'support/book'
require 'support/examples'
require 'support/tome'

module Spec::Support::Examples
  module RailsCommandExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'with parameters for a Rails command' do
      let(:data)                { [] }
      let(:mapped_data)         { defined?(super()) ? super() : data }
      let(:record_class)        { Book }
      let(:collection_name)     { 'books' }
      let(:constructor_options) { {} }
      let(:expected_options)    { {} }
      let(:primary_key_name)    { 'id' }
      let(:primary_key_type)    { Integer }
      let(:entity_type)         { record_class }
      let(:fixtures_data) do
        Cuprum::Collections::RSpec::BOOKS_FIXTURES.dup
      end
      let(:query) do
        Cuprum::Rails::Query.new(record_class)
      end
      let(:scope) do
        Cuprum::Rails::Query.new(record_class).where(scope_filter)
      end

      before(:example) do
        mapped_data.each { |attributes| record_class.create!(attributes) }
      end
    end

    shared_context 'with a custom primary key' do
      let(:collection_name)  { 'tomes' }
      let(:record_class)     { Tome }
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

    shared_examples 'should validate the :entity keyword' do
      describe 'with an invalid entity' do
        let(:entity) { Tome.new }
        let(:expected_error) do
          type     = record_class
          contract = Stannum::Contracts::ParametersContract.new do
            keyword :entity, type
          end
          errors = contract.errors_for({
            arguments: [],
            keywords:  { entity: entity },
            block:     nil
          })

          Cuprum::Collections::Errors::InvalidParameters.new(
            command: command,
            errors:  errors
          )
        end

        it 'should validate the :entity keyword' do
          expect(command.call(attributes: {}, entity: entity))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end
  end
end
