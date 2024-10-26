# frozen_string_literal: true

require 'cuprum/rails/action'
require 'cuprum/rails/actions/resources'
require 'cuprum/rails/actions/resources/concerns/resource_parameters'
require 'cuprum/rails/commands/resources/new'

module Cuprum::Rails::Actions::Resources
  # Action wrapper for performing a resourceful New request.
  class New < Cuprum::Rails::Action
    include Cuprum::Rails::Actions::Resources::Concerns::ResourceParameters

    private

    def build_response(value)
      { resource.singular_name => value }
    end

    def default_command_class
      Cuprum::Rails::Commands::Resources::New
    end

    def map_parameters
      { attributes: resource_params }
    end
  end
end
