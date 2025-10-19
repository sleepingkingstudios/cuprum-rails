# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/controllers'

module Cuprum::Rails::RSpec::Deferred::Controllers
  # @api private
  class MiddlewareMatcher # rubocop:disable Metrics/ClassLength
    extend Forwardable

    Options = Data.define(:actions, :formats, :matching, :middleware_class) do
      def initialize(middleware_class:, actions:, formats:, matching:, **rest)
        actions = build_actions(actions:, **rest)

        super(actions:, formats:, matching:, middleware_class:)
      end

      private

      def build_actions(actions:, except: [], only: []) # rubocop:disable Metrics/MethodLength
        return actions if actions.present?

        return actions unless except.present? || only.present?

        # :nocov:

        # @deprecate 0.3.0
        SleepingKingStudios::Tools::Toolbelt
          .instance
          .core_tools
          .deprecate(
            'include_deferred "should define middleware" with expect: ' \
            'or :only',
            message: 'Configure expected actions using the :actions keyword'
          )

        { except:, only: }
        # :nocov:
      end
    end

    def initialize(expected)
      @expected = expected
    end

    def_delegators :@expected,
      :actions,
      :formats,
      :matching,
      :middleware_class

    def failure_message
      message =
        "expected #{controller.name} to define middleware #{expected_name}"

      case failure_reason
      when :no_middleware
        "#{message}#{failure_message_for_no_middleware}"
      when :class_does_not_match
        "#{message}#{failure_message_for_class_does_not_match}"
      when :options_do_not_match
        "#{message}#{failure_reason_for_options_do_not_match}"
      end
    end

    def matches?(actual)
      @actual          = actual
      @failure_details = []
      @failure_reason  = nil
      @middleware      = []

      controller_defines_middleware? &&
        middleware_matches_class? &&
        middleware_matches_options?
    end

    private

    attr_reader :actual
    alias controller actual

    attr_reader :failure_details

    attr_reader :failure_reason

    attr_reader :middleware

    def actual_attributes_for(command)
      matching.each_key.to_h { |key| [key, command.public_send(key)] }
    end

    def controller_defines_middleware?
      return true unless controller.middleware.empty?

      @failure_reason = :no_middleware

      false
    end

    def expected_actions
      @expected_actions ||=
        Cuprum::Rails::Controllers::Middleware::InclusionMatcher
          .build(actions)
    end

    def expected_class
      return @expected_class if @expected_class

      @expected_class = middleware_class
    end

    def expected_name
      return expected_class.name if expected_class.is_a?(Class)

      # :nocov:

      # @deprecate 0.3.0
      expected_class.description
      # :nocov:
    end

    def expected_formats
      @expected_formats ||=
        Cuprum::Rails::Controllers::Middleware::InclusionMatcher
          .build(formats)
    end

    def expected_properties
      return @expected_properties if @expected_properties

      return if matching.nil?

      return @expected_properties = matching if matching.respond_to?(:matches?)

      @expected_properties =
        RSpec::Matchers::BuiltIn::HaveAttributes.new(matching)
    end

    def failure_message_for_class_does_not_match
      message = ", but the controller defines the following middleware:\n"

      controller
        .middleware
        .map(&:command)
        .map { |command| command.is_a?(Class) ? command : command.class }
        .map(&:name)
        .sort
        .uniq
        .each { |name| message += "\n  #{name}" }

      message
    end

    def failure_message_for_many
      message =
        "\n  #{controller} defines #{expected_name} #{middleware.size} times:"
      pattern = /\A( {6}\n){2} {6}/
      filler  = indent("\n\n", 6)

      middleware.each.with_index do |item, index|
        details  = format_failure_details(item, failure_details[index])
        details  = indent(details, 6)
        message += details.sub(pattern, "#{filler}  #{1 + index}): ")
      end

      message
    end

    def failure_message_for_one
      indent(
        format_failure_details(middleware.first, failure_details.first),
        2
      )
    end

    def failure_reason_for_options_do_not_match
      message = ', but no middleware matches the class and options:'

      if middleware.size == 1
        "#{message}#{failure_message_for_one}"
      else
        "#{message}#{failure_message_for_many}"
      end
    end

    def failure_message_for_no_middleware
      ', but the controller does not define middleware'
    end

    def find_matching_middleware # rubocop:disable Metrics/MethodLength
      matcher =
        if expected_class.is_a?(Class)
          RSpec::Matchers::BuiltIn::Match.new(expected_class)
        else
          # :nocov:

          # @deprecate 0.3.0
          SleepingKingStudios::Tools::Toolbelt
            .instance
            .core_tools
            .deprecate(
              'include_deferred "should define middleware" with expected: ' \
              'a matcher',
              message: 'Pass a matcher using the :matches keyword'
            )

          expected_class
          # :nocov:
        end

      controller.middleware.select do |config|
        matcher.matches?(config.command)
      end
    end

    def format_failure_details(middleware, details) # rubocop:disable Metrics/MethodLength
      message = ''

      if details.include?(:actions)
        message += "\n\n"
        message += format_inclusion_details(
          expected_actions,
          middleware.actions,
          as: 'actions'
        )
      end

      if details.include?(:formats)
        message += "\n\n"
        message += format_inclusion_details(
          expected_formats,
          middleware.formats,
          as: 'formats'
        )
      end

      if details.include?(:properties)
        message += "\n\n#{format_properties_details(middleware)}"
      end

      message
    end

    def format_hash(hsh)
      RSpec::Support::ObjectFormatter.format(hsh)
    end

    def format_inclusion_details(expected, actual, as:)
      message = "#{as.capitalize} do not match:\n"
      message += "\n  expected: #{format_inclusion_matcher(expected, as:)}"
      message += "\n    actual: #{format_inclusion_matcher(actual,   as:)}"

      message
    end

    def format_inclusion_matcher(matcher, as:)
      return "all #{as}" if matcher.nil?

      return "all #{as}" if matcher.except.empty? && matcher.only.empty?

      matcher
        .to_h
        .transform_values { |value| value.empty? ? nil : value.map(&:to_s) }
        .compact
        .to_s
    end

    def format_properties_details(middleware) # rubocop:disable Metrics/MethodLength
      failure_message =
        expected_properties
          .tap { |matcher| matcher.matches?(middleware.command) }
          .failure_message

      message = "Properties do not match:\n\n"

      message +=
        if matching.is_a?(Hash)
          expected = format_hash(matching)
          actual   = format_hash(actual_attributes_for(middleware.command))

          "  expected: #{expected}\n    actual: #{actual}"
        else
          indent(failure_message, 2)
        end

      message
    end

    def indent(string, count)
      spacer = ' ' * count

      string.each_line.map { |line| "#{spacer}#{line}" }.join
    end

    def match_actions?(middleware)
      actions =
        middleware.actions ||
        Cuprum::Rails::Controllers::Middleware::InclusionMatcher.new

      actions == expected_actions
    end

    def match_formats?(middleware)
      formats =
        middleware.formats ||
        Cuprum::Rails::Controllers::Middleware::InclusionMatcher.new

      formats == expected_formats
    end

    def match_options(middleware)
      details = []

      details << :actions    unless match_actions?(middleware)
      details << :formats    unless match_formats?(middleware)
      details << :properties unless match_properties?(middleware)

      details
    end

    def match_properties?(middleware)
      return true if expected_properties.nil?

      command = middleware.command
      command = command.new if command.is_a?(Class)

      expected_properties.matches?(command)
    end

    def middleware_matches_class?
      @middleware = find_matching_middleware

      return true unless middleware.empty?

      @failure_reason = :class_does_not_match

      false
    end

    def middleware_matches_options?
      @failure_details = middleware.map { |item| match_options(item) }

      return true if failure_details.any?(&:empty?)

      @failure_reason = :options_do_not_match

      false
    end
  end
end
