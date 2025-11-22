# frozen_string_literal: true

require 'cuprum/collections/rspec/fixtures'
require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/rails/rspec/deferred'

require 'support/book'

module Cuprum::Rails::RSpec::Deferred
  # Deferred examples for validating Scope classes.
  module ScopeExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include RSpec::SleepingKingStudios::Matchers::Macros

    deferred_examples 'should implement the Records::Scope methods' do
      deferred_context 'when the collection has many items' do
        let(:data) { Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES }
      end

      let(:data) { defined?(super()) ? super() : [] }

      before(:example) do
        data.each { |item| Book.create!(item) }
      end

      describe '#builder' do
        let(:expected) { Cuprum::Rails::Records::Scopes::Builder.instance }

        include_examples 'should define private reader',
          :builder,
          -> { expected }
      end

      describe '#build_relation' do
        let(:record_class) { defined?(super()) ? super() : Book }
        let(:relation) do
          subject.build_relation(record_class:)
        end

        it 'should define the method' do
          expect(scope)
            .to respond_to(:build_relation)
            .with(0).arguments
            .and_keywords(:record_class)
        end

        it { expect(relation).to be_a ActiveRecord::Relation }

        it { expect(relation.klass).to be record_class }
      end

      describe '#call' do
        it 'should define the method' do
          expect(subject)
            .to respond_to(:call)
            .with(0).arguments
            .and_keywords(:native_query)
        end

        describe 'with nil' do
          let(:error_message) { 'query must be an ActiveRecord::Relation' }

          it 'should raise an exception' do
            expect { subject.call(native_query: nil) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an Object' do
          let(:error_message) { 'query must be an ActiveRecord::Relation' }

          it 'should raise an exception' do
            expect { subject.call(native_query: Object.new.freeze) }
              .to raise_error ArgumentError, error_message
          end
        end
      end
    end
  end
end
