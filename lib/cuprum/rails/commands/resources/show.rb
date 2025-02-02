# frozen_string_literal: true

require 'cuprum/rails/commands/require_entity'
require 'cuprum/rails/commands/resource_command'
require 'cuprum/rails/commands/resources'

module Cuprum::Rails::Commands::Resources
  # Command implementing a Show action.
  class Show < Cuprum::Rails::Commands::ResourceCommand
    private

    def process(entity: nil, primary_key: nil, **)
      require_entity(entity:, primary_key:)
    end

    def require_entity(...)
      Cuprum::Rails::Commands::RequireEntity
        .new(collection:, require_primary_key: resource.plural?)
        .call(...)
    end
  end
end
