# frozen_string_literal: true

require 'cuprum/rails/serializers/json'
require 'cuprum/rails/serializers/json/serializer'

module Cuprum::Rails::Serializers::Json
  # Converts ActiveRecord record to JSON using the #as_json method.
  class ActiveRecordSerializer < Cuprum::Rails::Serializers::Json::Serializer
    # Converts the ActiveRecord record to JSON.
    #
    # Calls and returns the #as_json method of the record.
    #
    # @param record [ActiveRecord::Base] The record to convert to JSON.
    #
    # @return [Hash] a JSON-compatible representation of the record.
    def call(record, **_)
      unless record.is_a?(ActiveRecord::Base)
        raise ArgumentError, 'object must be an ActiveRecord record'
      end

      record.as_json
    end
  end
end
