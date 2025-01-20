# frozen_string_literal: true

require 'cuprum/rails/action'
require 'cuprum/rails/actions/resources'
require 'cuprum/rails/actions/resources/concerns/primary_key'
require 'cuprum/rails/commands/resources/destroy'

module Cuprum::Rails::Actions::Resources
  # Action wrapper for performing a resourceful Destroy request.
  class Destroy < Cuprum::Rails::Action
    include Cuprum::Rails::Actions::Resources::Concerns::PrimaryKey

    private

    def build_response(value)
      { resource.singular_name => value }
    end

    def default_command_class
      Cuprum::Rails::Commands::Resources::Destroy
    end

    def map_parameters
      return {} if resource.singular?

      primary_key = step { require_primary_key_value }

      { primary_key: }
    end
  end
end
