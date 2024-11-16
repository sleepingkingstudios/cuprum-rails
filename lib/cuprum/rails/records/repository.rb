# frozen_string_literal: true

require 'cuprum/collections/relations/parameters'
require 'cuprum/collections/repository'

require 'cuprum/rails/records'
require 'cuprum/rails/records/collection'

module Cuprum::Rails::Records
  # A repository represents a group of Records collections.
  class Repository < Cuprum::Collections::Repository
    private

    def build_collection(**options)
      Cuprum::Rails::Records::Collection.new(**options)
    end

    def qualified_name_for(**parameters)
      Cuprum::Collections::Relations::Parameters
        .resolve_parameters(parameters)
        .fetch(:qualified_name)
    end

    def valid_collection?(collection)
      collection.is_a?(Cuprum::Rails::Records::Collection)
    end
  end
end
