# frozen_string_literal: true

require 'cuprum/errors/uncaught_exception'

require 'cuprum/rails/action'
require 'cuprum/rails/actions/resource_methods'

module Cuprum::Rails::Actions
  # Abstract base class for resourceful actions.
  #
  # Each ResourceAction defines a series of steps used to validate and process
  # the action. Each step is performed in order:
  #
  # - The #validate_parameters step checks whether the request params are valid.
  #   For example, it may assert that the primary key is given for a member
  #   action, or that the attributes for a create or update action are present.
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
    include Cuprum::Rails::Actions::ResourceMethods

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

    def perform_action; end

    def process(request:)
      super

      handle_exceptions do
        step { validate_parameters }
        step { find_required_entities }
        step { perform_action }
        step { build_response }
      end
    end

    def validate_parameters; end
  end
end
