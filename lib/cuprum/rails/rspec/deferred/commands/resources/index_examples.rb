# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'cuprum/rails/rspec/deferred/commands/resources'
require 'cuprum/rails/rspec/deferred/commands/resources_examples'

module Cuprum::Rails::RSpec::Deferred::Commands::Resources
  # Deferred examples for validating Index command implementations.
  module IndexExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples

    deferred_examples 'should find the matching collection data' do
      let(:filtered_data) do
        defined?(super()) ? super() : collection_data
      end
      let(:ordered_data) do
        defined?(super()) ? super() : filtered_data
      end
      let(:matching_data) do
        defined?(super()) ? super() : ordered_data
      end
      let(:expected_data) do
        defined?(super()) ? super() : matching_data
      end

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_data)
      end
    end

    deferred_examples 'should implement the Index command' do
      describe '#call' do
        let(:collection_data) { defined?(super()) ? super() : [] }
        let(:command_options) { {} }

        def call_command
          defined?(super) ? super : command.call(**command_options)
        end

        it 'should define the method' do
          expect(command)
            .to be_callable
            .with(0).arguments
            .and_keywords(:limit, :offset, :order, :where)
            .and_any_keywords
        end

        describe 'with default parameters' do
          include_deferred 'should find the matching collection data'

          wrap_deferred 'when the collection has many items' do
            include_deferred 'should find the matching collection data'
          end
        end

        describe 'with limit: value' do
          let(:limit)           { defined?(super()) ? super() : 3 }
          let(:command_options) { super().merge(limit:) }
          let(:matching_data)   { ordered_data[...limit] || [] }

          include_deferred 'should find the matching collection data'

          wrap_deferred 'when the collection has many items' do
            include_deferred 'should find the matching collection data'
          end
        end

        describe 'with offset: value' do
          let(:offset)          { defined?(super()) ? super() : 2 }
          let(:command_options) { super().merge(offset:) }
          let(:matching_data)   { ordered_data[offset...] || [] }

          include_deferred 'should find the matching collection data'

          wrap_deferred 'when the collection has many items' do
            include_deferred 'should find the matching collection data'
          end
        end

        describe 'with order: value' do
          let(:order) do
            defined?(super()) ? super() : { 'title' => 'asc' }
          end
          let(:command_options) { super().merge(order:) }
          let(:ordered_data)    { sort_data(super()) }

          def sort_data(entities)
            return super if defined?(super)

            entities.sort_by { |entity| entity['title'] }
          end

          include_deferred 'should find the matching collection data'

          wrap_deferred 'when the collection has many items' do
            include_deferred 'should find the matching collection data'
          end
        end

        describe 'with where: a Hash' do
          let(:where_hash) do
            defined?(super()) ? super() : { 'author' => 'Ursula K. LeGuin' }
          end
          let(:command_options) { super().merge(where: where_hash) }
          let(:filtered_data)   { filter_data_hash(super()) }

          def filter_data_hash(entities)
            return super if defined?(super())

            entities.select do |entity|
              entity['author'] == 'Ursula K. LeGuin'
            end
          end

          include_deferred 'should find the matching collection data'

          wrap_deferred 'when the collection has many items' do
            include_deferred 'should find the matching collection data'
          end
        end

        context 'when the resource has a scope' do
          let(:resource_scope) do
            next super() if defined?(super())

            ->(query) { { 'series' => query.not_equal(nil) } }
          end
          let(:resource_options) do
            super().merge(scope: resource_scope)
          end
          let(:scoped_data) do
            next super() if defined?(super())

            collection_data.reject do |entity|
              entity['series'].nil?
            end
          end
          let(:filtered_data) { scoped_data }

          include_deferred 'should find the matching collection data'

          wrap_deferred 'when the collection has many items' do
            include_deferred 'should find the matching collection data'
          end

          describe 'with where: a Hash' do
            let(:where_hash) do
              defined?(super()) ? super() : { 'author' => 'Ursula K. LeGuin' }
            end
            let(:command_options) { super().merge(where: where_hash) }
            let(:filtered_data)   { filter_data_hash(super()) }

            def filter_data_hash(entities)
              return super if defined?(super())

              entities.select do |entity|
                entity['author'] == 'Ursula K. LeGuin'
              end
            end

            include_deferred 'should find the matching collection data'

            wrap_deferred 'when the collection has many items' do
              include_deferred 'should find the matching collection data'
            end
          end
        end
      end
    end
  end
end
