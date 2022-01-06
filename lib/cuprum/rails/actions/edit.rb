# frozen_string_literal: true

require 'cuprum/rails/actions'
require 'cuprum/rails/actions/resource_action'

module Cuprum::Rails::Actions
  # Action to find a resource instance by primary key.
  class Edit < Cuprum::Rails::Actions::ResourceAction
    private

    attr_reader :entity

    def build_response
      { singular_resource_name => entity }
    end

    def find_entity(primary_key:)
      collection.find_one.call(primary_key: primary_key)
    end

    def perform_action
      @entity = step { find_entity(primary_key: resource_id) }
    end

    def process(request:)
      @entity = nil

      super
    end

    def validate_parameters
      require_resource_id
    end
  end
end
