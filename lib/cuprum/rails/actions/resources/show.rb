# frozen_string_literal: true

require 'cuprum/rails/action'
require 'cuprum/rails/actions/resources'
require 'cuprum/rails/actions/resources/concerns/primary_key'
require 'cuprum/rails/commands/resources/show'

module Cuprum::Rails::Actions::Resources
  #  Action wrapper for performing a resourceful Show request.
  class Show < Cuprum::Rails::Action
    include Cuprum::Rails::Actions::Resources::Concerns::PrimaryKey

    private

    def build_response(value)
      { resource.singular_name => value }
    end

    def default_command_class
      Cuprum::Rails::Commands::Resources::Show
    end

    def map_parameters
      return {} if resource.singular?

      primary_key = step { require_primary_key_value }

      { primary_key: }
    end
  end
end
