# frozen_string_literal: true

require 'cuprum/rails/actions'
require 'cuprum/rails/actions/resource_action'

module Cuprum::Rails::Actions
  # Action to find a resource instance by primary key.
  class Show < Cuprum::Rails::Actions::ResourceAction
    private

    def process(request:)
      super

      step { require_resource_id }

      entity = step do
        collection.find_one.call(primary_key: resource_id)
      end

      { singular_resource_name => entity }
    end
  end
end
