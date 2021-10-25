# frozen_string_literal: true

require 'cuprum/rails/controller_action'
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
      own_actions[action_name] = Cuprum::Rails::ControllerAction.new(
        configuration,
        action_class:  action_class,
        action_name:   action_name,
        member_action: member
      )

      define_action(action_name)
    end

    # @return [Hash<Symbol, Cuprum::Rails::ControllerAction>] the actions
    #   defined for the controller.
    def actions
      ancestors
        .select { |ancestor| ancestor.respond_to?(:own_actions) }
        .reverse_each
        .map(&:own_actions)
        .reduce(&:merge)
    end

    # @private
    def own_actions
      @own_actions ||= {}
    end

    private

    def define_action(action_name)
      define_method(action_name) do
        request  = Cuprum::Rails::Request.build(request: self.request)
        action   = self.class.actions[action_name]
        response = action.call(request)
        response.call(self)
      end
    end
  end
end
