# frozen_string_literal: true

require 'cuprum/rails/actions'
require 'cuprum/rails/actions/resource_action'

module Cuprum::Rails::Actions
  # Action to build an empty resource instance.
  class New < Cuprum::Rails::Actions::ResourceAction
    private

    attr_reader :entity

    def build_entity
      collection.build_one.call(attributes: {})
    end

    def build_response
      { singular_resource_name => entity }
    end

    def perform_action
      @entity = step { build_entity }
    end

    def process(**)
      @entity = nil

      super
    end
  end
end
