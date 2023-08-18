# frozen_string_literal: true

require 'cuprum/collections'

require 'cuprum/rails'

module Cuprum::Rails
  # Abstract base class for Rails collection commands.
  class Command < Cuprum::Collections::Command
    # Creates a subclass with the given parameters applied to the constructor.
    def self.subclass(**default_options)
      Class.new(self) do
        define_method(:initialize) do |**options|
          super(**default_options.merge(options))
        end
      end
    end

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

    # @return [Symbol] the name of the primary key attribute.
    def primary_key_name
      @primary_key_name ||= record_class.primary_key
    end

    # @return [Class] the type of the primary key attribute.
    def primary_key_type
      @primary_key_type ||=
        case primary_key_column_type
        when :integer
          Integer
        when :uuid
          String
        else
          # :nocov:
          raise "unknown primary key column type :#{primary_key_column_type}"
          # :nocov:
        end
    end

    private

    def entity_contract
      type = record_class

      @entity_contract ||= Stannum::Contracts::ParametersContract.new do
        keyword :entity, type
      end
    end

    def primary_key_contract
      type = primary_key_type

      @primary_key_contract ||= Stannum::Contracts::ParametersContract.new do
        keyword :primary_key, type
      end
    end

    def primary_key_column_type
      record_class
        .columns
        .find { |column| column.name == record_class.primary_key }
        .type
    end

    def primary_keys_contract
      type = primary_key_type

      @primary_keys_contract ||= Stannum::Contracts::ParametersContract.new do
        keyword :primary_keys,
          Stannum::Constraints::Types::ArrayType.new(item_type: type)
      end
    end

    def resolve_collection_name(collection_name, record_class)
      return collection_name.to_s unless collection_name.nil?

      record_class.name.underscore.pluralize
    end

    def resolve_member_name(collection_name, member_name)
      return member_name.to_s unless member_name.nil?

      collection_name.singularize
    end

    def validate_entity(entity)
      match_parameters_to_contract(
        contract:    entity_contract,
        keywords:    { entity: entity },
        method_name: :call
      )
    end

    def validate_primary_key(primary_key)
      match_parameters_to_contract(
        contract:    primary_key_contract,
        keywords:    { primary_key: primary_key },
        method_name: :call
      )
    end

    def validate_primary_keys(primary_keys)
      match_parameters_to_contract(
        contract:    primary_keys_contract,
        keywords:    { primary_keys: primary_keys },
        method_name: :call
      )
    end
  end
end
