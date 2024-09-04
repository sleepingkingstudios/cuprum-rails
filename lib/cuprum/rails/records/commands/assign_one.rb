# frozen_string_literal: true

require 'stannum/constraints/types/hash_with_indifferent_keys'

require 'cuprum/collections/errors/extra_attributes'

require 'cuprum/rails/records/command'
require 'cuprum/rails/records/commands'

module Cuprum::Rails::Records::Commands
  # Command for assigning attributes to an ActiveRecord model.
  class AssignOne < Cuprum::Rails::Records::Command
    # @!method call(attributes:, entity:)
    #   Assigns the given attributes to the record.
    #
    #   Any attributes on the record that are not part of the given attributes
    #   hash are unchanged.
    #
    #   @param attributes [Hash] The attributes and values to update.
    #   @param entity [ActiveRecord::Base] The record to update.
    #
    #   @return [ActiveRecord::Base] a copy of the record, merged with the given
    #       attributes.
    #
    #   @example Assigning attributes
    #     entity = Book.new(
    #       'title'    => 'The Hobbit',
    #       'author'   => 'J.R.R. Tolkien',
    #       'series'   => nil,
    #       'category' => 'Science Fiction and Fantasy'
    #     )
    #     attributes = { title: 'The Silmarillion' }
    #     command    = Assign.new(record_class: Book)
    #     result     = command.call(attributes: attributes, entity: entity)
    #     result.value.attributes
    #     #=> {
    #       'id'       => nil,
    #       'title'    => 'The Silmarillion',
    #       'author'   => 'J.R.R. Tolkien',
    #       'series'   => nil,
    #       'category' => 'Science Fiction and Fantasy'
    #     }
    validate_parameters :call do
      keyword :attributes,
        Stannum::Constraints::Types::HashWithIndifferentKeys.new
      keyword :entity, Object
    end

    private

    def process(attributes:, entity:)
      step { validate_entity(entity) }

      entity.assign_attributes(attributes)

      entity
    rescue ActiveModel::UnknownAttributeError => exception
      error = Cuprum::Collections::Errors::ExtraAttributes.new(
        entity_class:     record_class,
        extra_attributes: [exception.attribute],
        valid_attributes: record_class.attribute_names
      )
      failure(error)
    end
  end
end
