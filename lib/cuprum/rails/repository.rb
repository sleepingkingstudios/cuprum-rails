# frozen_string_literal: true

require 'cuprum/collections/repository'

require 'cuprum/rails'
require 'cuprum/rails/collection'

module Cuprum::Rails
  # A repository represents a group of Rails collections.
  class Repository < Cuprum::Collections::Repository
    # Adds a new collection with the given record class to the repository.
    #
    # @param record_class [Class] The ActiveRecord class for the collection.
    # @param options [Hash] Additional options to pass to Collection.new
    #
    # @return [Cuprum::Rails::Collection] the created collection.
    #
    # @see Cuprum::Rails::Collection#initialize.
    #
    # @raise [Cuprum::Collections::Repository::DuplicateCollectionError] if the
    #   collection already exists in the repository.
    def create(record_class:, **options)
      validate_record_class!(record_class)

      collection = Cuprum::Rails::Collection.new(
        record_class: record_class,
        **options
      )

      add(collection)

      collection
    end

    # Finds or adds a collection with the given record class.
    #
    # @param record_class [Class] The ActiveRecord class for the collection.
    # @param options [Hash] Additional options to pass to Collection.new
    #
    # @return [Cuprum::Rails::Collection] the created collection.
    #
    # @see Cuprum::Rails::Collection#initialize.
    def find_or_create(record_class:, **options) # rubocop:disable Metrics/MethodLength
      validate_record_class!(record_class)

      collection = Cuprum::Rails::Collection.new(
        record_class: record_class,
        **options
      )

      if key?(collection.collection_name)
        other_collection = self[collection.collection_name]

        return other_collection if collection == other_collection
      end

      add(collection)

      collection
    end

    private

    def valid_collection?(collection)
      collection.is_a?(Cuprum::Rails::Collection)
    end

    def validate_record_class!(record_class)
      return if record_class.is_a?(Class) && record_class < ActiveRecord::Base

      raise ArgumentError, 'record class must be an ActiveRecord model'
    end
  end
end
