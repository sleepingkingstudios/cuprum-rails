# frozen_string_literal: true

require 'cuprum/rails/commands/resource_command'
require 'cuprum/rails/commands/resources'
require 'cuprum/rails/commands/resources/concerns/require_entity'

module Cuprum::Rails::Commands::Resources
  # Command implementing a Destroy action.
  class Destroy < Cuprum::Rails::Commands::ResourceCommand
    include Cuprum::Rails::Commands::Resources::Concerns::RequireEntity

    private

    def destroy_entity(primary_key:)
      collection.destroy_one.call(primary_key:)
    end

    def process(entity: nil, primary_key: nil, **)
      entity      = step { require_entity(entity:, primary_key:) }
      primary_key = entity[collection.primary_key_name]

      step { destroy_entity(primary_key:) }
    end
  end
end
