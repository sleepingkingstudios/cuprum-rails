# frozen_string_literal: true

require 'cuprum/errors/uncaught_exception'

require 'cuprum/rails/action'
require 'cuprum/rails/errors/resource_error'
require 'cuprum/rails/transaction'

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
    # @!method call(request:, resource:, repository: nil, **options)
    #   Performs the controller action.
    #
    #   Subclasses should implement a #process method with the :request keyword,
    #   which accepts an ActionDispatch::Request instance.
    #
    #   @param request [ActionDispatch::Request] the Rails request.
    #   @param resource [Cuprum::Rails::Resource] the controller resource.
    #   @param repository [Cuprum::Collections::Repository] the repository
    #     containing the data collections for the application or scope.
    #   @param options [Hash<Symbol, Object>] additional options for the action.
    #
    #   @return [Cuprum::Result] the result of the action.

    # @return [Cuprum::Rails::Records::Collection] the collection for the
    #   resource class.
    def collection
      @collection ||= repository.find_or_create(
        qualified_name: resource.qualified_name
      )
    end

    # @return [Cuprum::Rails::Resource] the controller resource.
    attr_reader :resource

    # @return [Object] the primary key for the resource.
    def resource_id
      @resource_id ||= params['id']
    end

    # @return [Hash] the permitted params for the resource.
    def resource_params
      return @resource_params if @resource_params

      resource_params = params.fetch(resource.singular_name, {})

      return resource_params unless resource_params.is_a?(Hash)

      @resource_params =
        resource_params
          .select { |key, _| permitted_attributes.include?(key) } # rubocop:disable Style/HashSlice
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
        exception:,
        message:   "uncaught exception in #{self.class.name} -"
      )
      failure(error)
    end

    def permitted_attributes
      @permitted_attributes ||=
        Set.new(resource.permitted_attributes.map(&:to_s))
    end

    def perform_action; end

    def process(resource:, **rest)
      @resource        = resource
      @resource_id     = nil
      @resource_params = nil

      step { require_permitted_attributes }

      super

      handle_exceptions do
        step { find_required_entities }
        step { perform_action }
        step { build_response }
      end
    end

    def require_permitted_attributes
      return unless require_permitted_attributes?

      return if resource.permitted_attributes.present?

      error = Cuprum::Rails::Errors::ResourceError.new(
        message:  "permitted attributes can't be blank",
        resource:
      )
      failure(error)
    end

    def require_permitted_attributes?
      false
    end

    def transaction(&)
      Cuprum::Rails::Transaction.new.call(&)
    end
  end
end
