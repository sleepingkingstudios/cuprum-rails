# frozen_string_literal: true

require 'cuprum/rails/commands/resources'
require 'cuprum/rails/commands/resources/concerns/permitted_attributes'

module Cuprum::Rails::Commands::Resources
  # Command implementing a New action.
  class New < Cuprum::Rails::Commands::ResourceCommand
    include Cuprum::Rails::Commands::Resources::Concerns::PermittedAttributes

    private

    def build_entity(attributes:)
      collection.build_one.call(attributes:)
    end

    def process(attributes: {}, **)
      permitted = step { permit_attributes(attributes:) }

      build_entity(attributes: permitted)
    end
  end
end
