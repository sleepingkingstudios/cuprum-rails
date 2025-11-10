# frozen_string_literal: true

require 'cuprum/rails/commands'

module Cuprum::Rails::Commands
  # Mixin for validating and applying required command resources.
  class ResourceCommand < Cuprum::Rails::Command
    # @param resource [Cuprum::Rails::Resource] the controller resource, if any.
    # @param repository [Cuprum::Collections::Repository] the repository
    #   containing the data collections for the application or scope.
    # @param options [Hash<Symbol, Object>] additional options for the command.
    def initialize(repository:, resource:, **options) # rubocop:disable Metrics/MethodLength
      tools.assertions.validate_instance_of(
        repository,
        as:       'repository',
        expected: Cuprum::Collections::Repository
      )
      tools.assertions.validate_instance_of(
        resource,
        as:       'resource',
        expected: Cuprum::Collections::Resource
      )

      super
    end

    private

    def collection
      @collection ||=
        repository
          .find(qualified_name: resource.qualified_name)
          .with_scope(resource.scope)
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
