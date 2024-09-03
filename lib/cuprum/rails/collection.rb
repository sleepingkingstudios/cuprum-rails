# frozen_string_literal: true

require 'cuprum/collections/collection'
require 'cuprum/command_factory'

require 'cuprum/rails'

module Cuprum::Rails
  # Wraps an ActiveRecord model as a Cuprum collection.
  class Collection < Cuprum::Collections::Collection
    command :assign_one do
      Cuprum::Rails::Commands::AssignOne.new(**command_options)
    end

    command :build_one do
      Cuprum::Rails::Commands::BuildOne.new(**command_options)
    end

    command :destroy_one do
      Cuprum::Rails::Commands::DestroyOne.new(**command_options)
    end

    command :find_many do
      Cuprum::Rails::Commands::FindMany.new(query:, **command_options)
    end

    command :find_matching do
      Cuprum::Rails::Commands::FindMatching.new(query:, **command_options)
    end

    command :find_one do
      Cuprum::Rails::Commands::FindOne.new(query:, **command_options)
    end

    command :insert_one do
      Cuprum::Rails::Commands::InsertOne.new(**command_options)
    end

    command :update_one do
      Cuprum::Rails::Commands::UpdateOne.new(**command_options)
    end

    command :validate_one do
      Cuprum::Rails::Commands::ValidateOne.new(**command_options)
    end

    # A new Query instance, used for querying against the collection data.
    #
    # @return [Cuprum::Rails::Query] the query.
    def query
      Cuprum::Rails::Query.new(entity_class, scope:)
    end

    protected

    def command_options
      super.merge(record_class: entity_class)
    end

    private

    def default_scope
      Cuprum::Rails::Scopes::AllScope.new
    end
  end
end
