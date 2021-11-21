# frozen_string_literal: true

require 'set'

require 'cuprum/rails/controllers'

module Cuprum::Rails::Controllers
  # A configured middleware option for a controller.
  class Middleware
    # @param command [Cuprum::Command] The middleware command to wrap the
    #   action or actions.
    # @param except [Array<Symbol>] A list of action names; the middleware will
    #   not be applied to actions on the list.
    # @param only [Array<Symbol>] A list of action names; the middleware will
    #   be applied only to actions on the list.
    def initialize(command:, except: [], only: [])
      @command = command
      @except  = Set.new(except.map(&:intern))
      @only    = Set.new(only.map(&:intern))
    end

    # @return [Cuprum::Middleware] the middleware command to wrap the action or
    #   actions.
    attr_reader :command

    # @return [Array<Symbol>] a list of action names; the middleware will not be
    #   applied to actions on the list.
    attr_reader :except

    # @return [Array<Symbol>] a list of action names; the middleware will be
    #   applied only to actions on the list.
    attr_reader :only

    # @private
    def ==(other)
      other.is_a?(Cuprum::Rails::Controllers::Middleware) &&
        other.command == command &&
        other.except  == except &&
        other.only    == only
    end

    # Checks if the middleware will be applied to the named action.
    #
    # If the middleware defines any :except actions, returns false if the action
    # name is in the set. If the middleware defines any :only actions, returns
    # false unless the action name is in the set. Otherwise, returns true.
    #
    # @param action_name [Symbol] The name of the action.
    #
    # @return [true, false] whether the middleware will be applied.
    def matches?(action_name)
      return false unless except.empty? || except.exclude?(action_name)
      return false unless only.empty?   || only.include?(action_name)

      true
    end
    alias match? matches?
  end
end
