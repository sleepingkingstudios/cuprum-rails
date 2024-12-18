# frozen_string_literal: true

require 'cuprum/collections/collection'
require 'cuprum/command_factory'

require 'cuprum/rails/records'
require 'cuprum/rails/records/scopes/all_scope'

module Cuprum::Rails::Records
  # Wraps an ActiveRecord model as a Cuprum collection.
  class Collection < Cuprum::Collections::Collection
    command :assign_one do
      Cuprum::Rails::Records::Commands::AssignOne.new(collection: self)
    end

    command :build_one do
      Cuprum::Rails::Records::Commands::BuildOne.new(collection: self)
    end

    command :destroy_one do
      Cuprum::Rails::Records::Commands::DestroyOne.new(collection: self)
    end

    command :find_many do
      Cuprum::Rails::Records::Commands::FindMany.new(collection: self)
    end

    command :find_matching do
      Cuprum::Rails::Records::Commands::FindMatching.new(collection: self)
    end

    command :find_one do
      Cuprum::Rails::Records::Commands::FindOne.new(collection: self)
    end

    command :insert_one do
      Cuprum::Rails::Records::Commands::InsertOne.new(collection: self)
    end

    command :update_one do
      Cuprum::Rails::Records::Commands::UpdateOne.new(collection: self)
    end

    command :validate_one do
      Cuprum::Rails::Records::Commands::ValidateOne.new(collection: self)
    end

    # @return [String] the name of the primary key attribute.
    def primary_key_name
      @primary_key_name ||=
        options.fetch(:primary_key_name, entity_class&.primary_key || 'id').to_s
    end

    # @return [Class, Stannum::Constraint] the type of the primary key
    #   attribute. Defaults to Integer.
    def primary_key_type
      @primary_key_type ||=
        options
          .fetch(:primary_key_type, resolve_primary_key_type)
          .then { |obj| obj.is_a?(String) ? Object.const_get(obj) : obj }
    end

    # A new Query instance, used for querying against the collection data.
    #
    # @return [Cuprum::Rails::Records::Query] the query.
    def query
      Cuprum::Rails::Records::Query.new(entity_class, scope:)
    end

    private

    def default_scope
      Cuprum::Rails::Records::Scopes::AllScope.new
    end

    def primary_key_column_type
      entity_class
        &.columns
        &.find { |column| column.name == primary_key_name }
        &.type
    end

    def resolve_primary_key_type
      column_type = primary_key_column_type

      return Integer unless column_type

      case column_type
      when :string, :uuid
        String
      else
        Integer
      end
    end
  end
end
