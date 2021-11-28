# frozen_string_literal: true

require 'forwardable'

require 'cuprum/rails/actions'
require 'cuprum/rails/errors/missing_parameters'
require 'cuprum/rails/errors/missing_primary_key'
require 'cuprum/rails/errors/undefined_permitted_attributes'

module Cuprum::Rails::Actions
  # Abstract base class for resourceful actions.
  class ResourceAction < Cuprum::Rails::Action
    extend Forwardable

    # @param options [Hash<Symbol, Object>] Additional options for the action.
    # @param repository [Cuprum::Collections::Repository] The repository
    #   containing the data collections for the application or scope.
    # @param resource [Cuprum::Rails::Resource] The controller resource.
    def initialize(resource:, repository: nil, **options)
      if resource.collection.nil?
        raise ArgumentError, 'resource must have a collection'
      end

      super
    end

    def_delegators :@resource,
      :collection,
      :resource_name,
      :singular_resource_name

    # @return [Object] the primary key for the resource.
    def resource_id
      return success(params[:id]) if params[:id].present?

      failure(missing_primary_key_error)
    end

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

    def missing_primary_key_error
      Cuprum::Rails::Errors::MissingPrimaryKey.new(
        primary_key:   resource.primary_key,
        resource_name: singular_resource_name
      )
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
