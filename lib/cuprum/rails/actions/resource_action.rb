# frozen_string_literal: true

require 'forwardable'

require 'cuprum/rails/actions'
require 'cuprum/rails/errors/missing_parameters'
require 'cuprum/rails/errors/undefined_permitted_attributes'

module Cuprum::Rails::Actions
  # Abstract base class for resourceful actions.
  class ResourceAction < Cuprum::Rails::Action
    extend Forwardable

    # @param resource [Cuprum::Rails::Resource] The controller resource.
    def initialize(resource:)
      if resource.collection.nil?
        raise ArgumentError, 'resource must have a collection'
      end

      super
    end

    def_delegators :@resource,
      :collection,
      :resource_name,
      :singular_resource_name

    # @return [Hash] the permitted params for the resource.
    def resource_params
      return failure(permitted_attributes_error) unless permitted_attributes?

      success(raw_resource_params)
    rescue ActionController::ParameterMissing
      failure(missing_parameters_error)
    end

    private

    def missing_parameters_error
      Cuprum::Rails::Errors::MissingParameters
        .new(resource_name: singular_resource_name)
    end

    def permitted_attributes?
      !resource.permitted_attributes.nil?
    end

    def permitted_attributes_error
      Cuprum::Rails::Errors::UndefinedPermittedAttributes
        .new(resource_name: singular_resource_name)
    end

    def raw_resource_params
      params
        .require(singular_resource_name)
        .permit(*resource.permitted_attributes)
        .to_hash
    end
  end
end
