# frozen_string_literal: true

require 'cuprum/rails/commands/permit_attributes'
require 'cuprum/rails/commands/resource_command'
require 'cuprum/rails/commands/resources'

module Cuprum::Rails::Commands::Resources
  # Command implementing a New action.
  class New < Cuprum::Rails::Commands::ResourceCommand
    private

    def build_entity(attributes:)
      collection.build_one.call(attributes:)
    end

    def permit_attributes(attributes:)
      Cuprum::Rails::Commands::PermitAttributes.new(resource:).call(attributes:)
    end

    def process(attributes: {}, **)
      permitted = step { permit_attributes(attributes:) }

      build_entity(attributes: permitted)
    end
  end
end
