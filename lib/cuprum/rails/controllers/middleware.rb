# frozen_string_literal: true

require 'set'

require 'cuprum/rails/controllers'

module Cuprum::Rails::Controllers
  # A configured middleware option for a controller.
  class Middleware
    # Utility class for matching a value against included and excluded sets.
    InclusionMatcher = Data.define(:except, :only) do
      # Generates a matcher from the value.
      #
      # @overload build(value)
      #   Converts a non-empty value to a string and generates a matcher.
      #
      #   The matcher will only match the given value.
      #
      #   @param value [Object, nil] the value to match.
      #
      #   @return [Cuprum::Rails::Controllers::Middleware::InclusionMatcher]
      #     the generated matcher.
      #
      # @overload build(array)
      #   Converts the given values to strings and generates a matcher.
      #
      #   The matcher will match any of the given values.
      #
      #   @param array [Array] the values to match.
      #
      #   @return [Cuprum::Rails::Controllers::Middleware::InclusionMatcher]
      #     the generated matcher.
      #
      # @overload build(hash)
      #   Generates a matcher using the :except and :only values, if any.
      #
      #   @param hash [Hash] the parameters to match against.
      #
      #   @return [Cuprum::Rails::Controllers::Middleware::InclusionMatcher]
      #     the generated matcher.
      def self.build(value)
        return new if value.blank?

        if value.is_a?(Hash)
          return new(**value.transform_values { |item| Array(item) })
        end

        new(only: Array(value))
      end

      # @param except [Array<String, Symbol>] values to be excluded from the
      #   matcher.
      # @param only [Array<String, Symbol>] values to be included in the
      #   matcher.
      def initialize(except: [], only: [])
        super(
          except: Set.new(except&.map(&:to_s)),
          only:   Set.new(only&.map(&:to_s))
        )
      end

      # Checks if the value matches the expected values.
      #
      # If the matcher defines any :except values, returns false if the value
      # matches any :except value. If the matcher defines any :only values,
      # returns false unless the value matches any :only value. Returns true if
      # neither of those checks fails.
      #
      # @param value [String, Symbol] the value to match.
      #
      # @return [true, false] true if the value matches the expected values;
      #   otherwise false.
      def matches?(value)
        value = value.to_s

        return false unless except.empty? || except.exclude?(value)
        return false unless only.empty?   || only.include?(value)

        true
      end
      alias_method :match?, :matches?
    end

    # @param command [Cuprum::Command] The middleware command to wrap the
    #   action or actions.
    # @param actions [Cuprum::Rails::Controllers::Middleware::InclusionMatcher]
    #   the actions that match the middleware.
    # @param formats [Cuprum::Rails::Controllers::Middleware::InclusionMatcher]
    #   the formsats that match the middleware.
    def initialize(command:, actions: nil, formats: nil)
      @command = command
      @actions = actions
      @formats = formats
    end

    # @return [Cuprum::Rails::Controllers::Middleware::InclusionMatcher] the
    #   actions that match the middleware.
    attr_reader :actions

    # @return [Cuprum::Middleware] the middleware command to wrap the action or
    #   actions.
    attr_reader :command

    # @return [Cuprum::Rails::Controllers::Middleware::InclusionMatcher] the
    #   formats that match the middleware.
    attr_reader :formats

    # @private
    def ==(other)
      other.is_a?(Cuprum::Rails::Controllers::Middleware) &&
        other.command == command &&
        other.actions == actions &&
        other.formats == formats
    end

    # Checks if the middleware will be applied to the given request.
    #
    # Applies the inclusion and exclusion filters defined for actions, if any,
    # to the request.
    #
    # @param request [Symbol] the request to match.
    #
    # @return [true, false] whether the middleware will be applied.
    def matches?(request)
      unless actions.blank? || actions.matches?(request.action_name)
        return false
      end

      return false unless formats.blank? || formats.matches?(request.format)

      true
    end
    alias match? matches?
  end
end
