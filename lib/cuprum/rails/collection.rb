# frozen_string_literal: true

require 'cuprum/collections/collection'
require 'cuprum/command_factory'

require 'cuprum/rails'

module Cuprum::Rails
  # Wraps an ActiveRecord model as a Cuprum collection.
  class Collection < Cuprum::Collections::Collection
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
