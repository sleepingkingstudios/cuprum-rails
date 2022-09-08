# frozen_string_literal: true

require 'cuprum/errors/uncaught_exception'

require 'cuprum/rails/action'
require 'cuprum/rails/actions/parameter_validation'

module Cuprum::Rails::Actions
  # Abstract base class for resourceful actions.
  #
  # Each ResourceAction defines a series of steps used to validate and process
  # the action. Each step is performed in order:
  #
  # - The #find_required_entities step locates any dependent entities and
  #   ensures that the entities exist. For example, it may find the requested
  #   entity for a show action, or the parent entity for a create action on a
  #   nested resource.
  # - The #perform_action step contains the core logic of the action. For
  #   example, in a destroy action it would take the entity (located in the
  #   previous step) and remove it from the collection.
  # - The #build_response step generates the result returned by a successful
  #   request. For example, for a show action on a nested resource, it might
  #   build a passing result with both the requested and parent resources.
  #
  # If any of the steps fail, either by returning a failing result or by raising
  # an exception, the action will immediately stop execution and return the
  # result, or wrap the exception in a failing result with a
  # Cuprum::Errors::UncaughtException error.
  class ResourceAction < Cuprum::Rails::Action
    include Cuprum::Rails::Actions::ParameterValidation

    # @param options [Hash<Symbol, Object>] Additional options for the action.
    # @param repository [Cuprum::Collections::Repository] The repository
    #   containing the data collections for the application or scope.
    # @param resource [Cuprum::Rails::Resource] The controller resource.
    def initialize(resource:, repository: nil, **options)
      if resource.collection.nil?
        raise ArgumentError, 'resource must have a collection'
      end

      if require_permitted_attributes?
        permitted = resource.permitted_attributes

        if !permitted.is_a?(Array) || permitted.empty?
          raise ArgumentError, 'resource must define permitted attributes'
        end
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

    def build_response
      Cuprum::Result.new(status: :success)
    end

    def find_required_entities; end

    def handle_exceptions
      yield
    rescue StandardError => exception
      error = Cuprum::Errors::UncaughtException.new(
        exception: exception,
        message:   "uncaught exception in #{self.class.name} -"
      )
      failure(error)
    end

    def permitted_attributes
      @permitted_attributes ||=
        Set.new(resource.permitted_attributes.map(&:to_s))
    end

    def perform_action; end

    def process(request:)
      super

      @resource_id     = nil
      @resource_params = nil

      handle_exceptions do
        step { find_required_entities }
        step { perform_action }
        step { build_response }
      end
    end

    def require_permitted_attributes?
      false
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
