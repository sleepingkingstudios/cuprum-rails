# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'cuprum/rails/rspec/deferred/commands/resources'
require 'cuprum/rails/rspec/deferred/commands/resources_examples'

module Cuprum::Rails::RSpec::Deferred::Commands::Resources
  # Deferred examples for validating Index command implementations.
  module IndexExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples

    # Examples that assert on the entities data returned by the command.
    #
    # The following methods must be defined in the example group:
    #
    # - #call_command: A method that calls the command being tested with all
    #   required parameters.
    # - #collection_data: A method that calls the command being tested with all
    #   required parameters.
    #
    # The behavior can be customized by defining the following methods:
    #
    # - #filtered_data: All entities matching the command's attribute filters,
    #   such as a :where clause or a collection scope. Defaults to the value of
    #   #collection_data.
    # - #ordered_data: The filtered data in the order returned by the command.
    #   Defaults to the value of #filtered_data.
    # - #matching_data: The subset of the ordered data returned by the command,
    #   such as :limit or :offset clauses. Defaults to the value of
    #   #ordered_data.
    # - #expected_data: The actual items returned by the command, including any
    #   additional processing. Defaults to the value of #matching_data.
    # - #expected_value: The value returned by the command. Defaults to the
    #   value of #expected_data.
    deferred_examples 'should find the matching collection data' do
      include RSpec::SleepingKingStudios::Deferred::Dependencies

      depends_on :call_command,
        'method that calls the command being tested with required parameters'
      depends_on :collection_data,
        'the entities defined in the collection'

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
      let(:expected_value) do
        defined?(super()) ? super() : expected_data
      end

      it 'should return a passing result', :aggregate_failures do
        result = call_command

        expect(result).to be_a_passing_result
        expect(result.value).to match(expected_value)
      end
    end

    # Examples that assert the command implements the Create contract.
    #
    # This example group handles the following cases:
    #
    # - with no parameters.
    # - with a :limit parameter.
    # - with an :offset parameter.
    # - with an :order parameter.
    # - with a :where parameter.
    # - when the resource has a scope.
    # - with a :where parameter when the resource has a scope.
    #
    # The following methods must be defined in the example group:
    #
    # - #order: A valid ordering for the collection.
    # - #resource_scope: Must return a Cuprum::Collections::Scope that matches a
    #   subset of the fixtures.
    # - #where_hash: A valid attributes filter for the collection.
    deferred_examples 'should implement the Index command' do |&block|
      include RSpec::SleepingKingStudios::Deferred::Dependencies

      depends_on :order,
        'a valid ordering for the collection'
      depends_on :resource_scope,
        'a Cuprum::Collections::Scope that matches a subset of the fixtures'
      depends_on :where_hash,
        'a valid attributes filter for the collection'

      describe '#call' do
        let(:collection_data) { [] }
        let(:command_options) { {} }

        define_method :call_command do
          defined?(super()) ? super() : command.call(**command_options)
        end

        include_deferred 'when the collection is defined'

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
          let(:command_options) { super().merge(order:) }
          let(:ordered_data)    { sort_data(super()) }

          define_method :sort_data do |entities|
            return super(entities) if defined?(super(entities))

            entities.sort_by { |entity| entity['title'] }
          end

          include_deferred 'should find the matching collection data'

          wrap_deferred 'when the collection has many items' do
            include_deferred 'should find the matching collection data'
          end
        end

        describe 'with where: a Hash' do
          let(:command_options) { super().merge(where: where_hash) }
          let(:filtered_data) do
            collection
              .with_scope(where_hash)
              .find_matching
              .call
              .value
              .to_a
          end

          include_deferred 'should find the matching collection data'

          wrap_deferred 'when the collection has many items' do
            include_deferred 'should find the matching collection data'
          end
        end

        context 'when the resource has a scope' do
          let(:resource_options) { super().merge(scope: resource_scope) }
          let(:filtered_data) do
            collection
              .with_scope(resource_scope)
              .find_matching
              .call
              .value
              .to_a
          end

          include_deferred 'should find the matching collection data'

          wrap_deferred 'when the collection has many items' do
            include_deferred 'should find the matching collection data'
          end

          describe 'with where: a Hash' do
            let(:command_options) { super().merge(where: where_hash) }
            let(:filtered_data) do
              collection
                .with_scope(resource_scope)
                .with_scope(where_hash)
                .find_matching
                .call
                .value
                .to_a
            end

            include_deferred 'should find the matching collection data'

            wrap_deferred 'when the collection has many items' do
              include_deferred 'should find the matching collection data'
            end
          end
        end

        instance_exec(&block) if block
      end
    end
  end
end
