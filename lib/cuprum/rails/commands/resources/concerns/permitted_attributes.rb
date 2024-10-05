# frozen_string_literal: true

require 'cuprum/rails/commands/resources/concerns'
require 'cuprum/rails/errors/resource_error'

module Cuprum::Rails::Commands::Resources::Concerns
  # Helper methods for handling resourceful permitted attributes.
  module PermittedAttributes
    private

    def permit_attributes(attributes:)
      step { require_permitted_attributes }

      return attributes if permitted_attributes.blank?

      attributes = tools.hash_tools.convert_keys_to_strings(attributes)

      attributes.slice(*permitted_attributes)
    end

    def permitted_attributes
      @permitted_attributes ||= resource.permitted_attributes&.map(&:to_s)
    end

    def require_permitted_attributes
      return unless require_permitted_attributes?

      return if permitted_attributes.present?

      error = Cuprum::Rails::Errors::ResourceError.new(
        message:  "permitted attributes can't be blank",
        resource:
      )
      failure(error)
    end

    def require_permitted_attributes?
      true
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
