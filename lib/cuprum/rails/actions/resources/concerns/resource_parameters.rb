# frozen_string_literal: true

require 'cuprum/rails/actions/resources/concerns'

module Cuprum::Rails::Actions::Resources::Concerns
  # Shared methods for mapping resource parameters.
  module ResourceParameters
    private

    def resource_params
      params[resource.name] || {}
    end
  end
end
