# frozen_string_literal: true

require 'cuprum/collections/collection'
require 'cuprum/command_factory'

require 'cuprum/rails'

module Cuprum::Rails
  # Wraps an ActiveRecord model as a Cuprum collection.
  class Collection < Cuprum::Collections::Collection
    alias record_class entity_class

    # @param collection_name [String, Symbol] the name of the collection.
    # @param entity_class [Class, String] the class of entity represented in the
    #   collection.
    # @param record_class [Class, String] alternative keyword for entity class.
    # @param options [Hash<Symbol>] additional options for the collection.
    #
    # @option options member_name [String] the name of a collection entity.
    # @option options primary_key_name [String] the name of the primary key
    #   attribute. Defaults to 'id'.
    # @option options primary_key_type [Class, Stannum::Constraint] the type of
    #   the primary key attribute. Defaults to Integer.
    # @option options qualified_name [String] the qualified name of the
    #   collection, which should be unique. Defaults to the collection name.
    def initialize(
      collection_name: nil,
      entity_class:    nil,
      record_class:    nil,
      **options
    )
      super(
        collection_name: collection_name,
        entity_class:    entity_class || record_class,
        **options
      )
    end

    command_class :assign_one do
      Cuprum::Rails::Commands::AssignOne
        .subclass(**command_options)
    end

    command_class :build_one do
      Cuprum::Rails::Commands::BuildOne
        .subclass(**command_options)
    end

    command_class :destroy_one do
      Cuprum::Rails::Commands::DestroyOne
        .subclass(**command_options)
    end

    command_class :find_many do
      Cuprum::Rails::Commands::FindMany
        .subclass(**command_options)
    end

    command_class :find_matching do
      Cuprum::Rails::Commands::FindMatching
        .subclass(**command_options)
    end

    command_class :find_one do
      Cuprum::Rails::Commands::FindOne
        .subclass(**command_options)
    end

    command_class :insert_one do
      Cuprum::Rails::Commands::InsertOne
        .subclass(**command_options)
    end

    command_class :update_one do
      Cuprum::Rails::Commands::UpdateOne
        .subclass(**command_options)
    end

    command_class :validate_one do
      Cuprum::Rails::Commands::ValidateOne
        .subclass(**command_options)
    end

    # @param other [Object] The object to compare.
    #
    # @return [true, false] true if the other object is a collection with the
    #   same options, otherwise false.
    def ==(other)
      return false unless other.is_a?(self.class)

      other.collection_name == collection_name &&
        other.member_name == member_name &&
        other.qualified_name == qualified_name &&
        other.entity_class == entity_class &&
        other.options == options
    end

    # A new Query instance, used for querying against the collection data.
    #
    # @return [Cuprum::Rails::Query] the query.
    def query
      Cuprum::Rails::Query.new(entity_class)
    end

    private

    def command_options
      super().merge(record_class: entity_class)
    end
  end
end
