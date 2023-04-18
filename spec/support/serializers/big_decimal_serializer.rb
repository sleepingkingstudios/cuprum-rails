# frozen_string_literal: true

require 'bigdecimal'

require 'cuprum/rails/serializers/base_serializer'

require 'support/serializers'

module Spec::Support::Serializers
  class BigDecimalSerializer < Cuprum::Rails::Serializers::BaseSerializer
    def call(value, **_)
      value.to_s
    end
  end
end
