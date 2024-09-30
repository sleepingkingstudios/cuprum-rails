# frozen_string_literal: true

require 'cuprum/rails/action'
require 'cuprum/rails/actions/resources'
require 'cuprum/rails/actions/resources/concerns/resource_parameters'

module Cuprum::Rails::Actions::Resources
  # Generic action for wrapping resourceful commands.
  class Action < Cuprum::Rails::Action
    include Cuprum::Rails::Actions::Resources::Concerns::ResourceParameters

    private

    def build_response(value)
      { resource.singular_name => value }
    end

    def map_parameters
      { attributes: resource_params }
    end
  end
end
