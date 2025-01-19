# frozen_string_literal: true

require 'cuprum/rails/action'
require 'cuprum/rails/actions/resources'
require 'cuprum/rails/actions/resources/concerns/entity_validation'
require 'cuprum/rails/actions/resources/concerns/primary_key'
require 'cuprum/rails/actions/resources/concerns/resource_parameters'
require 'cuprum/rails/commands/resources/create'

module Cuprum::Rails::Actions::Resources
  # Action wrapper for performing a resourceful Update request.
  class Update < Cuprum::Rails::Action
    include Cuprum::Rails::Actions::Resources::Concerns::EntityValidation
    include Cuprum::Rails::Actions::Resources::Concerns::PrimaryKey
    include Cuprum::Rails::Actions::Resources::Concerns::ResourceParameters

    private

    def build_response(value)
      { resource.singular_name => value }
    end

    def default_command_class
      Cuprum::Rails::Commands::Resources::Update
    end

    def map_parameters
      resource_params = step { require_resource_params }

      hsh = { attributes: resource_params }

      return hsh if resource.singular?

      primary_key = step { require_primary_key_value }

      hsh.merge(primary_key:)
    end
  end
end
