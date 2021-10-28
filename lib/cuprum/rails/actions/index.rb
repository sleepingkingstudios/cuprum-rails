# frozen_string_literal: true

require 'cuprum/rails/actions'
require 'cuprum/rails/actions/resource_action'

module Cuprum::Rails::Actions
  # Action to find and filter resources.
  class Index < Cuprum::Rails::Actions::ResourceAction
    def_delegators :@resource,
      :default_order

    private

    # @note Overload this method to change how the filtering params are defined,
    #   or override the #limit, #offset, #order, #where methods directly.
    def filter_params
      tools.hash_tools.convert_keys_to_strings(request.params)
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

    def process(request:)
      super

      filters = where
      block   = where.present? ? -> { filters } : nil

      collection.find_matching.call(
        envelope: true,
        limit:    limit,
        offset:   offset,
        order:    order,
        &block
      )
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    def where
      filter_params['where']
    end
  end
end
