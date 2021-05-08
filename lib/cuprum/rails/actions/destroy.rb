# frozen_string_literal: true

require 'cuprum/rails/actions'
require 'cuprum/rails/actions/resource_action'

module Cuprum::Rails::Actions
  # Action to delete a resource instance by primary key.
  class Destroy < Cuprum::Rails::Actions::ResourceAction
    private

    def process(request:)
      super

      primary_key = step { resource_id }
      resource    = step do
        collection.destroy_one.call(primary_key: primary_key)
      end

      { singular_resource_name => resource }
    end
  end
end
