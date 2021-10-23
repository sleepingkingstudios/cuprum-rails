# frozen_string_literal: true

require 'cuprum/rails'
require 'cuprum/rails/controller_action'

module Cuprum::Rails
  # Provides a DSL for defining actions and responses.
  #
  # @example Defining A Controller
  #   class ExampleController < ApplicationController
  #     include Cuprum::Rails::Controller
  #
  #     responder :html, CustomHtmlResponder
  #
  #     action :process, ExampleProcessAction
  #   end
  #
  # @example Defining A RESTful Controller
  #   class BooksController
  #     include Cuprum::Rails::Controller
  #
  #     responder :html, Cuprum::Rails::Responders::Html::PluralResource
  #
  #     action :index,     Cuprum::Rails::Actions::Index
  #     action :show,      Cuprum::Rails::Actions::Show, member: true
  #     action :published, Books::Published
  #     action :publish,   Books::Publish,               member: true
  #   end
  module Controller
    # Provides a DSL for defining controller actions and responders.
    module ClassMethods
      # Defines a controller action.
      #
      # @param action_name [String, Symbol] The name of the action.
      # @param action_class [Class] The class of the action command. Must be
      #   constructible with keyword :resource.
      # @param member [Boolean] True if the action acts on a collection item,
      #   not on the collection as a whole.
      def action(action_name, action_class, member: false)
        validate_name(action_name, as: 'action name')
        validate_class(action_class, as: 'action class')

        action_name              = action_name.intern
        own_actions[action_name] = Cuprum::Rails::ControllerAction.new(
          action_class:  action_class,
          action_name:   action_name,
          member_action: member
        )

        define_action(action_name)
      end

      # @private
      def actions
        ancestors
          .select { |ancestor| ancestor < Cuprum::Rails::Controller }
          .reverse_each
          .map(&:own_actions)
          .reduce(&:merge)
      end

      # @private
      def own_actions
        @own_actions ||= {}
      end

      # @private
      #
      # @todo Document .own_responders
      def own_responders
        @own_responders ||= {}
      end

      # Assigns a responder class to handle requests of the specified format.
      #
      # @param format [String, Symbol] The request format to handle.
      # @param responder_class [Class] The class of responder.
      def responder(format, responder_class)
        validate_name(format, as: 'format')
        validate_class(responder_class, as: 'responder')

        own_responders[format.intern] = responder_class
      end

      # @private
      def responders
        ancestors
          .select { |ancestor| ancestor < Cuprum::Rails::Controller }
          .reverse_each
          .map(&:own_responders)
          .reduce(&:merge)
      end

      private

      def define_action(action_name)
        define_method(action_name) do
          action   = self.class.actions[action_name]
          response = action.call(
            request:         request,
            resource:        resource,
            responder_class: responder_class
          )
          response.call(self)
        end
      end

      def validate_class(value, as:) # rubocop:disable Naming/MethodParameterName
        return if value.is_a?(Class)

        raise ArgumentError, "#{as} must be a Class", caller(1..-1)
      end

      def validate_name(value, as:) # rubocop:disable Naming/MethodParameterName
        raise ArgumentError, "#{as} can't be blank", caller(1..-1) if value.nil?

        unless value.is_a?(String) || value.is_a?(Symbol)
          raise ArgumentError,
            "#{as} must be a String or Symbol",
            caller(1..-1)
        end

        return unless value.to_s.empty?

        raise ArgumentError, "#{as} can't be blank", caller(1..-1)
      end
    end

    # Exception when the controller does not define a resource.
    class UndefinedResourceError < StandardError; end

    # Exception when the controller does not have a responder for a format.
    class UnknownFormatError < StandardError; end

    # @private
    def self.included(other)
      super

      other.extend(ClassMethods)
    end

    # Returns the resource defined for the controller.
    #
    # Controller subclasses must override this method.
    #
    # @return [Cuprum::Rails::Resource] the resource defined for the controller.
    #
    # @raise [Cuprum::Rails::Controller::UndefinedResourceError] if the
    #   controller does not define a resource.
    def resource
      raise UndefinedResourceError, "no resource defined for #{self.class.name}"
    end

    # Returns the responder class corresponding to the request format.
    #
    # @return [Class] the matching responder class.
    #
    # @raise [Cuprum::Rails::Controller::UnknownFormatError] if the controller
    #   does not define a responder for the given format.
    def responder_class
      format = request.format.symbol

      self.class.responders.fetch(format) do
        raise UnknownFormatError,
          "no responder registered for format #{format.inspect}"
      end
    end
  end
end
