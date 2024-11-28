# frozen_string_literal: true

require 'cuprum/rails/commands/resource_command'
require 'cuprum/rails/commands/resources'
require 'cuprum/rails/commands/resources/concerns/require_entity'

module Cuprum::Rails::Commands::Resources
  # Command implementing a Show action.
  class Show < Cuprum::Rails::Commands::ResourceCommand
    include Cuprum::Rails::Commands::Resources::Concerns::RequireEntity

    private

    def process(entity: nil, primary_key: nil, **)
      require_entity(entity:, primary_key:)
    end
  end
end
