# frozen_string_literal: true

require 'cuprum/rails/actions'
require 'cuprum/rails/actions/resource_action'

module Cuprum::Rails::Actions
  # Action to find a resource instance by primary key.
  class Show < Cuprum::Rails::Actions::ResourceAction
    private

    def process(request:)
      super

      primary_key = step { resource_id }
      entity      = step do
        collection.find_one.call(primary_key: primary_key)
      end

      { singular_resource_name => entity }
    end
  end
end
