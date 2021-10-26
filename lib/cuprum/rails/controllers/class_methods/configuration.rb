# frozen_string_literal: true

require 'cuprum/rails/controllers/class_methods'
require 'cuprum/rails/controllers/configuration'

module Cuprum::Rails::Controllers::ClassMethods
  # Provides a DSL for defining controller configuration.
  module Configuration
    # @return [Cuprum::Rails::Controllers::Configuration] the configured options
    #   for the controller.
    def configuration
      Cuprum::Rails::Controllers::Configuration.new(self)
    end

    # @private
    def own_responders
      @own_responders ||= {}
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
      {}
    end
  end
end
