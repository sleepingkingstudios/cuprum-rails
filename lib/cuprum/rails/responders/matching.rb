# frozen_string_literal: true

require 'cuprum/matcher'
require 'cuprum/matcher_list'

require 'cuprum/rails/responders'

module Cuprum::Rails::Responders
  # Implements matching an action result to a response clause.
  module Matching
    # Provides a DSL for generating response clauses for matching results.
    module ClassMethods
      # Creates a match clause that maps a result to a response.
      #
      # @param status [Symbol] The status of the result, either :success or
      #   :failure.
      # @param error [Class] The class of the result error. If given, the clause
      #   will only match results with an error that is an instance of this
      #   class or a subclass.
      # @param value [Class] The class of the result value. If given, the clause
      #   will only match results with a value that is an instance of this class
      #   or a subclass.
      #
      # @yield The clause implementation. This block will be called in the
      #   context of the matcher.
      # @yieldreturn [#call, #renderer] the response for the action.
      def match(status, error: nil, value: nil, &block)
        matcher = @matcher || Cuprum::Matcher.new

        matcher.singleton_class.match(
          status, error: error, value: value, &block
        )

        @matcher = matcher
      end

      # @private
      def matchers(**_keywords)
        return [] unless @matcher

        [@matcher]
      end

      private

      attr_reader :matcher
    end

    # @private
    def self.included(other)
      super

      other.extend(ClassMethods)
    end

    # @param action_name [String, Symbol] The name of the action to match.
    # @param matcher [Cuprum::Matcher] An optional matcher specific to the
    #   action. This will be matched before any of the generic matchers.
    # @param member_action [Boolean] True if the action acts on a collection
    #   item, not on the collection as a whole.
    # @param resource [Cuprum::Rails::Resource] The resource for the controller.
    def initialize(
      action_name:,
      resource:,
      matcher: nil,
      member_action: false,
      **options
    )
      super(
        action_name:   action_name,
        member_action: member_action,
        resource:      resource,
        **options
      )

      @matcher = matcher
    end

    # @return [Cuprum::Matcher] an optional matcher specific to the action.
    attr_reader :matcher

    # Finds and calls the response clause that matches the given result.
    #
    # 1.  Checks for an exact match (the result status, value, and error all
    #     match) in the given matcher (if any), then the responder class, then
    #     each ancestor of the responder class in ascending order.
    # 2.  If a match is not found, checks for a partial match (the result
    #     status, and either the value or the error match) in the same order.
    # 3.  If there is still no match found, checks for a generic match (the
    #     result status matches, and the match clause does not specify either an
    #     error or a value.
    # 4.  If there is no matching response clause, raises an exception.
    #
    # @param result [Cuprum::Result] the result of the action call.
    #
    # @return [#call] the response object from the matching response clause.
    #
    # @raise [Cuprum::Matching::NoMatchError] if none of the response clauses
    #   match the result.
    def call(result)
      @result = result

      Cuprum::MatcherList
        .new(matchers.map { |matcher| matcher.with_context(self) })
        .call(result)
    end

    # @return [Symbol, nil] the format of the responder.
    def format
      nil
    end

    # @return [Boolean] true if the action acts on a collection item, not on the
    #   collection as a whole.
    def member_action?
      @member_action
    end

    private

    def class_matchers
      options = matcher_options

      singleton_class
        .ancestors
        .select { |ancestor| ancestor < Cuprum::Rails::Responders::Matching }
        .map { |ancestor| ancestor.matchers(**options) }
        .flatten
    end

    def matcher_options
      {}
    end

    def matchers
      return class_matchers if matcher.nil?

      [matcher, *class_matchers]
    end
  end
end
