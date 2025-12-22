# frozen_string_literal: true

require 'cuprum/collections/collection_command'
require 'cuprum/collections/errors/already_exists'
require 'cuprum/collections/errors/not_found'

require 'cuprum/rails/errors/invalid_statement'
require 'cuprum/rails/records'

module Cuprum::Rails::Records
  # Abstract base class for Records collection commands.
  class Command < Cuprum::Collections::CollectionCommand
    # @return [Class] the ActiveRecord class for the collection.
    def record_class
      collection.entity_class
    end

    private

    def already_exists_error(primary_key)
      Cuprum::Collections::Errors::AlreadyExists.new(
        attribute_name:  primary_key_name,
        attribute_value: primary_key,
        name:,
        primary_key:     true
      )
    end

    def extra_attributes_error(extra_attributes)
      Cuprum::Collections::Errors::ExtraAttributes.new(
        entity_class:     record_class,
        extra_attributes:,
        valid_attributes: record_class.attribute_names
      )
    end

    def invalid_statement_error(message)
      Cuprum::Rails::Errors::InvalidStatement.new(message:)
    end

    def not_found_error(primary_key)
      Cuprum::Collections::Errors::NotFound.new(
        attribute_name:  primary_key_name,
        attribute_value: primary_key,
        name:,
        primary_key:     true
      )
    end

    def validate_entity(value, as: 'entity')
      return if value.is_a?(collection.entity_class)

      tools.assertions.error_message_for(
        'sleeping_king_studios.tools.assertions.instance_of',
        as:,
        expected: collection.entity_class
      )
    end
  end
end
