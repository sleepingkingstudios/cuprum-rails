# frozen_string_literal: true

require 'cuprum/collections/errors/extra_attributes'

require 'cuprum/rails/records/command'
require 'cuprum/rails/records/commands'

module Cuprum::Rails::Records::Commands
  # Command for generating an ActiveRecord model from an attributes hash.
  class BuildOne < Cuprum::Rails::Records::Command
    # @!method call(attributes:)
    #   Builds a new record with the given attributes.
    #
    #   @param attributes [Hash] The attributes and values to assign.
    #
    #   @return [ActiveRecord::Base] the newly built record.
    #
    #   @example Building a record
    #     attributes = {
    #       'title'    => 'The Hobbit',
    #       'author'   => 'J.R.R. Tolkien',
    #       'series'   => nil,
    #       'category' => 'Science Fiction and Fantasy'
    #     }
    #     command    = Build.new(record_class: Book)
    #     result     = command.call(attributes: attributes)
    #     result.value.attributes
    #     #=> {
    #       'id'       => nil,
    #       'title'    => 'The Silmarillion',
    #       'author'   => 'J.R.R. Tolkien',
    #       'series'   => nil,
    #       'category' => 'Science Fiction and Fantasy'
    #     }
    validate :attributes

    private

    def process(attributes:)
      record_class.new(attributes)
    rescue ActiveModel::UnknownAttributeError => exception
      failure(extra_attributes_error([exception.attribute]))
    end
  end
end
