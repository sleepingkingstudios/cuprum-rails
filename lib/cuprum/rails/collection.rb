# frozen_string_literal: true

require 'cuprum/command_factory'

require 'cuprum/rails'

module Cuprum::Rails
  # Wraps an ActiveRecord model as a Cuprum collection.
  class Collection < Cuprum::CommandFactory
    # @param collection_name [String, Symbol] The name of the collection.
    # @param member_name [String] The name of a collection entity.
    # @param options [Hash<Symbol>] Additional options for the command.
    # @param record_class [Class] The ActiveRecord class for the collection.
    def initialize(
      record_class:,
      collection_name: nil,
      member_name:     nil,
      **options
    )
      super()

      @collection_name = resolve_collection_name(collection_name, record_class)
      @member_name     = resolve_member_name(@collection_name, member_name)
      @record_class    = record_class
      @options         = options
    end

    # @return [String] The name of the collection.
    attr_reader :collection_name

    # @return [String] the name of a collection entity.
    attr_reader :member_name

    # @return [Hash<Symbol>] additional options for the command.
    attr_reader :options

    # @return [Class] the ActiveRecord class for the collection.
    attr_reader :record_class

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
        other.record_class == record_class &&
        other.options == options
    end

    # A new Query instance, used for querying against the collection data.
    #
    # @return [Cuprum::Rails::Query] the query.
    def query
      Cuprum::Rails::Query.new(record_class)
    end

    private

    def command_options
      @command_options ||= {
        collection_name: collection_name,
        member_name:     member_name,
        record_class:    record_class,
        **options
      }
    end

    def resolve_collection_name(collection_name, record_class)
      return collection_name.to_s unless collection_name.nil?

      record_class.name.underscore.pluralize
    end

    def resolve_member_name(collection_name, member_name)
      return member_name.to_s unless member_name.nil?

      collection_name.singularize
    end
  end
end
