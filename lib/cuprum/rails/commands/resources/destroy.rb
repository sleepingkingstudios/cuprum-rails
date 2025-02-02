# frozen_string_literal: true

require 'cuprum/rails/commands/require_entity'
require 'cuprum/rails/commands/resource_command'
require 'cuprum/rails/commands/resources'

module Cuprum::Rails::Commands::Resources
  # Command implementing a Destroy action.
  class Destroy < Cuprum::Rails::Commands::ResourceCommand
    private

    def destroy_entity(primary_key:)
      collection.destroy_one.call(primary_key:)
    end

    def process(entity: nil, primary_key: nil, **)
      entity      = step { require_entity(entity:, primary_key:) }
      primary_key = entity[collection.primary_key_name]

      step { destroy_entity(primary_key:) }
    end

    def require_entity(...)
      Cuprum::Rails::Commands::RequireEntity
        .new(collection:, require_primary_key: resource.plural?)
        .call(...)
    end
  end
end
