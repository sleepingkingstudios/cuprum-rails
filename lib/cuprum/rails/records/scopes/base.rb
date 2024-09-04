# frozen_string_literal: true

require 'cuprum/collections/scopes/base'

require 'cuprum/rails/records/scopes'

module Cuprum::Rails::Records::Scopes
  # Abstract class representing a set of filters for a Rails query.
  class Base < Cuprum::Collections::Scopes::Base
    # Generates an ActiveRecord relation for the scope and given record class.
    def build_relation(record_class:)
      process(native_query: record_class.all)
    end

    # Applies the scope to the given ActiveRecord query.
    def call(native_query:)
      unless native_query.is_a?(ActiveRecord::Relation)
        raise ArgumentError, 'query must be an ActiveRecord::Relation'
      end

      process(native_query:)
    end

    private

    def builder
      Cuprum::Rails::Records::Scopes::Builder.instance
    end

    def process(native_query:)
      native_query
    end
  end
end

require 'cuprum/rails/records/scopes/builder'
