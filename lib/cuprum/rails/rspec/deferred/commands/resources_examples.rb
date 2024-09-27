# frozen_string_literal: true

require 'cuprum/collections/rspec/fixtures'
require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/rails/rspec/deferred/commands'

module Cuprum::Rails::RSpec::Deferred::Commands
  # Deferred examples for validating resource command implementations.
  module ResourcesExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_context 'when the collection has many items' do
      let(:collection) do
        repository.find_or_create(qualified_name: resource.qualified_name)
      end
      let(:fixtures_data) do
        next super() if defined?(super())

        Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
      end
      let(:collection_data) do
        fixtures_data
      end

      before(:example) do
        collection_data.each do |entity|
          result = collection.insert_one.call(entity:)

          # :nocov:
          next if result.success?

          raise result.error.message
          # :nocov:
        end
      end
    end
  end
end
