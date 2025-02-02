# frozen_string_literal: true

require 'cuprum/rails/commands/permit_attributes'
require 'cuprum/rails/commands/resource_command'
require 'cuprum/rails/commands/resources'
require 'cuprum/rails/commands/resources/concerns/require_entity'

module Cuprum::Rails::Commands::Resources
  # Command implementing an Edit action.
  class Edit < Cuprum::Rails::Commands::ResourceCommand
    include Cuprum::Rails::Commands::Resources::Concerns::RequireEntity

    private

    def permit_attributes(attributes:)
      Cuprum::Rails::Commands::PermitAttributes.new(resource:).call(attributes:)
    end

    def process(attributes: {}, entity: nil, primary_key: nil, **)
      entity    = step { require_entity(entity:, primary_key:) }
      permitted = step { permit_attributes(attributes:) }

      step { update_entity(attributes: permitted, entity:) }
    end

    def update_entity(attributes:, entity:)
      collection.assign_one.call(attributes:, entity:)
    end
  end
end
