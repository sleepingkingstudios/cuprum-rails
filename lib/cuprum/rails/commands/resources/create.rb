# frozen_string_literal: true

require 'cuprum/rails/commands/resource_command'
require 'cuprum/rails/commands/resources'
require 'cuprum/rails/commands/resources/concerns/entity_validation'
require 'cuprum/rails/commands/resources/concerns/permitted_attributes'

module Cuprum::Rails::Commands::Resources
  # Command implementing a Create action.
  class Create < Cuprum::Rails::Commands::ResourceCommand
    include Cuprum::Rails::Commands::Resources::Concerns::EntityValidation
    include Cuprum::Rails::Commands::Resources::Concerns::PermittedAttributes

    private

    def build_entity(attributes:)
      collection.build_one.call(attributes:)
    end

    def persist_entity(entity:)
      collection.insert_one.call(entity:)
    end

    def process(attributes: {}, **)
      permitted = step { permit_attributes(attributes:) }
      entity    = step { build_entity(attributes: permitted) }

      step { validate_entity(entity:) }

      persist_entity(entity:)
    end
  end
end
