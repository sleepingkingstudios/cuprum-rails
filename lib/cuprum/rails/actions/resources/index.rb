# frozen_string_literal: true

require 'cuprum/rails/actions/resources'
require 'cuprum/rails/commands/resources/index'

module Cuprum::Rails::Actions::Resources
  # Action wrapper for performing a resourceful Index request.
  class Index < Cuprum::Rails::Action
    private

    def build_response(value)
      { resource.name => value }
    end

    def default_command_class
      Cuprum::Rails::Commands::Resources::Index
    end

    # @note Overload this method to change how the filtering params are defined,
    #   or override the #limit, #offset, #order, #where methods directly.
    def filter_params
      tools.hash_tools.convert_keys_to_strings(request.params)
    end

    def limit
      filter_params['limit']
    end

    def map_parameters
      {
        limit:,
        offset:,
        order:,
        where:
      }
    end

    def offset
      filter_params['offset']
    end

    def order
      filter_params['order']
    end

    def where
      filter_params['where']
    end
  end
end
