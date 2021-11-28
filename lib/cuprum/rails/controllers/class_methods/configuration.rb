# frozen_string_literal: true

require 'cuprum/rails/controllers/class_methods'
require 'cuprum/rails/controllers/configuration'
require 'cuprum/rails/serializers/json'

module Cuprum::Rails::Controllers::ClassMethods
  # Provides a DSL for defining controller configuration.
  module Configuration
    # @return [Cuprum::Rails::Controllers::Configuration] the configured options
    #   for the controller.
    def configuration
      Cuprum::Rails::Controllers::Configuration.new(self)
    end

    # @overload default_format
    #   @return [Symbol] the default format for controller requests.
    #
    # @overload default_format(format)
    #   Sets the default format for controller requests.
    #
    #   @param format [String, Symbol] The format to set as default.
    def default_format(format = nil)
      if format.nil?
        return @default_format if @default_format

        return superclass.default_format if controller_class?(superclass)

        return nil
      end

      validate_name(format, as: 'format')

      @default_format = format.intern
    end

    # @private
    def own_responders
      @own_responders ||= {}
    end

    # Returns the repository defined for the controller.
    #
    # @return [Cuprum::Collections::Repository] the repository containing the
    #   data collections for the application or scope.
    def repository
      nil
    end

    # Returns the resource defined for the controller.
    #
    # Controller subclasses must override this method.
    #
    # @return [Cuprum::Rails::Resource] the resource defined for the
    #   controller.
    #
    # @raise [Cuprum::Rails::Controller::UndefinedResourceError] if the
    #   controller does not define a resource.
    def resource
      raise Cuprum::Rails::Controller::UndefinedResourceError,
        "no resource defined for #{name}"
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

    # @return [Hash<Symbol, Class>] the responder classes defined for the
    #   controller, by format.
    def responders
      ancestors
        .select { |ancestor| ancestor.respond_to?(:own_responders) }
        .reverse_each
        .map(&:own_responders)
        .reduce(&:merge)
    end

    # @return [Hash<Class, Object>, Hash<Symbol, Hash<Class, Object>>] the
    #   serializers for converting result values into serialized data.
    def serializers
      {
        json: Cuprum::Rails::Serializers::Json.default_serializers
      }
    end

    private

    def controller_class?(other)
      other.singleton_class <
        Cuprum::Rails::Controllers::ClassMethods::Configuration
    end
  end
end
