# frozen_string_literal: true

require 'cuprum/rails/commands'

module Cuprum::Rails::Commands
  # Utility command for filtering attributes.
  class PermitAttributes < Cuprum::Command
    # @param resource [Cuprum::Rails::Resource] the resource defining the
    #   permitted attributes.
    # @param require_permitted_attributes [true, false] if true, an exception
    #   will be raised when the command is called and the resource's permitted
    #   attributes are empty.
    def initialize(resource:, require_permitted_attributes: true)
      super()

      @resource                     = resource
      @require_permitted_attributes = require_permitted_attributes
    end

    # @return [Cuprum::Rails::Resource] the resource defining the permitted
    #   attributes.
    attr_reader :resource

    # @return [true, false] if true, an exception will be raised when the
    #   command is called and the resource's permitted attributes are empty.
    def require_permitted_attributes?
      @require_permitted_attributes
    end

    private

    def permitted_attributes
      @permitted_attributes ||= resource.permitted_attributes&.map(&:to_s)
    end

    def process(attributes:)
      step { require_permitted_attributes }

      attributes = tools.hash_tools.convert_keys_to_strings(attributes)

      return attributes if permitted_attributes.blank?

      attributes.slice(*permitted_attributes)
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

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
