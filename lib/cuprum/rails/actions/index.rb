# frozen_string_literal: true

require 'cuprum/rails/actions'
require 'cuprum/rails/actions/resource_action'

module Cuprum::Rails::Actions
  # Action to find and filter resources.
  class Index < Cuprum::Rails::Actions::ResourceAction
    def_delegators :@resource,
      :default_order

    private

    def process(request:)
      super

      collection.find_matching.call(
        envelope: true,
        order:    default_order.presence
      )
    end
  end
end
