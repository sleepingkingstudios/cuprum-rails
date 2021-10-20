# frozen_string_literal: true

require 'cuprum/rails/serializers'

module Cuprum::Rails::Serializers
  # Namespace for JSON serializers, which convert objects to a JSON format.
  module Json
    autoload :ArraySerializer,
      'cuprum/rails/serializers/json/array_serializer'
    autoload :HashSerializer,
      'cuprum/rails/serializers/json/hash_serializer'
    autoload :IdentitySerializer,
      'cuprum/rails/serializers/json/identity_serializer'
    autoload :Serializer, 'cuprum/rails/serializers/json/serializer'

    # Default serializers for handling value objects and data structures.
    #
    # @return [Hash<Class, Cuprum::Rails::Serializers::Json::Serializer>] the
    #   default serializers.
    def self.default_serializers
      @default_serializers ||= {
        Array      => self::ArraySerializer.instance,
        Hash       => self::HashSerializer.instance,
        FalseClass => self::IdentitySerializer.instance,
        Float      => self::IdentitySerializer.instance,
        Integer    => self::IdentitySerializer.instance,
        NilClass   => self::IdentitySerializer.instance,
        String     => self::IdentitySerializer.instance,
        TrueClass  => self::IdentitySerializer.instance
      }
    end
  end
end
