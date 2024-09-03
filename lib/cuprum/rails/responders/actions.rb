# frozen_string_literal: true

require 'cuprum/matcher'

require 'cuprum/rails/responders'

module Cuprum::Rails::Responders
  # Implements matching a result to action-specific response clauses.
  module Actions
    # Provides a DSL for generating action-specific response clauses.
    module ClassMethods
      # Creates a new response matcher specific to the specified action.
      #
      # @param action_name [String, Symbol] The name of the action.
      #
      # @yield The matcher definition.
      def action(action_name, &block)
        validate_action_name!(action_name)

        actions[action_name.intern] = Cuprum::Matcher.new(&block)

        nil
      end

      # @private
      def actions
        @actions ||= {}
      end

      # @private
      def matchers(action_name: nil, **_keywords)
        return super unless action_name

        action = actions[action_name.intern]

        action.nil? ? super : [action, *super]
      end

      private

      def validate_action_name!(action_name)
        if action_name.nil? || action_name.to_s.empty?
          raise ArgumentError, "action name can't be blank", caller(1..-1)
        end

        return if action_name.is_a?(String) || action_name.is_a?(Symbol)

        raise ArgumentError, 'action name must be a String or Symbol',
          caller(1..-1)
      end
    end

    # @!method call(result)
    #   (see Cuprum::Rails::Responders::Matching#call)
    #
    #   If the responder defines an action matcher that matches the given action
    #   name, that matcher is matched against the result before any match
    #   clauses defined directly on the responder.

    # @private
    def self.included(other)
      super

      other.extend(ClassMethods)
    end

    private

    def matcher_options
      super.merge(action_name: action_name)
    end
  end
end
