# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Namespace for serializers, which convert objects to a serialized format.
  module Serializers
    autoload :BaseSerializer, 'cuprum/rails/serializers/base_serializer'
    autoload :Context,        'cuprum/rails/serializers/context'
    autoload :Json,           'cuprum/rails/serializers/json'
  end
end
