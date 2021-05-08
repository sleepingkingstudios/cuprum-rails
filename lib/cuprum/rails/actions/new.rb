# frozen_string_literal: true

require 'cuprum/rails/actions'
require 'cuprum/rails/actions/resource_action'

module Cuprum::Rails::Actions
  # Action to build an empty resource instance.
  class New < Cuprum::Rails::Actions::ResourceAction
    private

    def process(request:)
      super

      instance = step { collection.build_one.call(attributes: {}) }

      { singular_resource_name => instance }
    end
  end
end
