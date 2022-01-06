# frozen_string_literal: true

require 'forwardable'

require 'cuprum/rails/actions'
require 'cuprum/rails/errors/missing_parameters'
require 'cuprum/rails/errors/missing_primary_key'
require 'cuprum/rails/errors/undefined_permitted_attributes'

module Cuprum::Rails::Actions
  # Helper methods for defining resourceful actions.
  module ResourceMethods
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
      :resource_class,
      :resource_name,
      :singular_resource_name

    # @return [Object] the primary key for the resource.
    def resource_id
      @resource_id = params['id']
    end

    # @return [Hash] the permitted params for the resource.
    def resource_params
      return @resource_params if @resource_params

      resource_params = params.fetch(singular_resource_name, {})

      return resource_params unless resource_params.is_a?(Hash)

      @resource_params =
        resource_params
          .select { |key, _| permitted_attributes.include?(key) }
          .to_h
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

    def permitted_attributes
      @permitted_attributes ||=
        Set.new(resource.permitted_attributes.map(&:to_s))
    end

    def permitted_attributes?
      !resource.permitted_attributes.nil?
    end

    def permitted_attributes_error
      Cuprum::Rails::Errors::UndefinedPermittedAttributes
        .new(resource_name: singular_resource_name)
    end

    def process(request:)
      super

      @resource_id     = nil
      @resource_params = nil
    end

    def require_resource_id
      return if resource_id.present?

      failure(missing_primary_key_error)
    end

    def require_resource_params
      return failure(permitted_attributes_error) unless permitted_attributes?

      return if resource_params.is_a?(Hash) && resource_params.present?

      failure(missing_parameters_error)
    end

    def transaction(&block) # rubocop:disable Metrics/MethodLength
      result            = nil
      transaction_class =
        if resource_class.is_a?(Class) && resource_class < ActiveRecord::Base
          resource_class
        else
          ActiveRecord::Base
        end

      transaction_class.transaction do
        result = steps { block.call }

        raise ActiveRecord::Rollback if result.failure?
      end

      result
    end
  end
end
