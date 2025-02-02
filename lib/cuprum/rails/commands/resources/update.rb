# frozen_string_literal: true

require 'cuprum/rails/commands/permit_attributes'
require 'cuprum/rails/commands/resource_command'
require 'cuprum/rails/commands/resources'
require 'cuprum/rails/commands/resources/concerns/require_entity'
require 'cuprum/rails/commands/validate_entity'

module Cuprum::Rails::Commands::Resources
  # Command implementing an Update action.
  class Update < Cuprum::Rails::Commands::ResourceCommand
    include Cuprum::Rails::Commands::Resources::Concerns::RequireEntity

    private

    def permit_attributes(attributes:)
      Cuprum::Rails::Commands::PermitAttributes.new(resource:).call(attributes:)
    end

    def persist_entity(entity:)
      collection.update_one.call(entity:)
    end

    def process(attributes: {}, entity: nil, primary_key: nil, **)
      entity    = step { require_entity(entity:, primary_key:) }
      permitted = step { permit_attributes(attributes:) }
      entity    = step { update_entity(attributes: permitted, entity:) }

      step { validate_entity(entity:) }

      persist_entity(entity:)
    end

    def update_entity(attributes:, entity:)
      collection.assign_one.call(attributes:, entity:)
    end

    def validate_entity(entity:)
      Cuprum::Rails::Commands::ValidateEntity.new(collection:).call(entity:)
    end
  end
end
