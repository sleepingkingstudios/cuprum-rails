# frozen_string_literal: true

require 'cuprum/rails/commands/permit_attributes'
require 'cuprum/rails/commands/resource_command'
require 'cuprum/rails/commands/resources'
require 'cuprum/rails/commands/validate_entity'

module Cuprum::Rails::Commands::Resources
  # Command implementing a Create action.
  class Create < Cuprum::Rails::Commands::ResourceCommand
    private

    def build_entity(attributes:)
      collection.build_one.call(attributes:)
    end

    def permit_attributes(attributes:)
      Cuprum::Rails::Commands::PermitAttributes.new(resource:).call(attributes:)
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

    def validate_entity(entity:)
      Cuprum::Rails::Commands::ValidateEntity.new(collection:).call(entity:)
    end
  end
end
