# frozen_string_literal: true

require 'cuprum/rails/controllers/action'
require 'cuprum/rails/controllers/class_methods'

module Cuprum::Rails::Controllers::ClassMethods
  # Provides a DSL for defining controller actions.
  module Actions
    # Defines a controller action.
    #
    # @param action_name [String, Symbol] The name of the action.
    # @param action_class [Class] The class of the action command. Must be
    #   constructible with keyword :resource.
    # @param member [Boolean] True if the action acts on a collection item, not
    #   on the collection as a whole.
    def action(action_name, action_class, member: false)
      validate_name(action_name, as: 'action name')
      validate_class(action_class, as: 'action class')

      action_name              = action_name.intern
      own_actions[action_name] = Cuprum::Rails::Controllers::Action.new(
        action_class:  action_class,
        action_name:   action_name,
        member_action: member
      )

      define_action(action_name)
    end

    # @return [Hash<Symbol, Cuprum::Rails::Controllers::Action>] the actions
    #   defined for the controller.
    def actions
      ancestors
        .select { |ancestor| ancestor.respond_to?(:own_actions) }
        .reverse_each
        .map(&:own_actions)
        .reduce(&:merge)
    end

    # @private
    def apply_request_defaults(request)
      request.format ||= configuration.default_format
    end

    # Generates a Cuprum::Rails::Request from a native request.
    #
    # Override this method to generate a request subclass.
    #
    # @param context [#request] the controller or controller context.
    # @param options [Hash{Symbol=>Object}] additional options for the request.
    #
    # @return [Cuprum::Rails::Request] the generated request.
    def build_request(context, **options)
      Cuprum::Rails::Request.build(
        context: context,
        request: context.request,
        **options
      )
    end

    # @private
    def own_actions
      # :nocov:
      @own_actions ||= {}
      # :nocov:
    end

    private

    def define_action(action_name)
      define_method(action_name) do
        action  = self.class.actions[action_name]
        request =
          self
            .class
            .build_request(self, member_action: action.member_action?)
            .tap { |req| self.class.apply_request_defaults(req) }
        response = action.call(self, request)
        response.call(self)
      end
    end
  end
end
