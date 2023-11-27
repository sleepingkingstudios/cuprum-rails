# frozen_string_literal: true

require 'cuprum/rails/actions'
require 'cuprum/rails/actions/resource_action'

module Cuprum::Rails::Actions
  # Action to find and filter resources.
  class Index < Cuprum::Rails::Actions::ResourceAction
    def_delegators :@resource,
      :default_order

    private

    attr_reader :entities

    def build_response
      { resource.name => entities.to_a }
    end

    # @note Overload this method to change how the filtering params are defined,
    #   or override the #limit, #offset, #order, #where methods directly.
    def filter_params
      tools.hash_tools.convert_keys_to_strings(request.params)
    end

    def find_entities(limit:, offset:, order:, &block)
      collection.find_matching.call(
        limit:  limit,
        offset: offset,
        order:  order,
        &block
      )
    end

    def limit
      filter_params['limit']
    end

    def offset
      filter_params['offset']
    end

    def order
      filter_params.fetch('order', default_order.presence)
    end

    def perform_action
      filters = where
      block   = where.present? ? -> { filters } : nil

      @entities = step do
        find_entities(
          limit:  limit,
          offset: offset,
          order:  order,
          &block
        )
      end
    end

    def process(**)
      @entities = nil

      super
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    def where
      filter_params['where']
    end
  end
end
