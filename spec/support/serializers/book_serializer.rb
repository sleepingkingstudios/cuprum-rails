# frozen_string_literal: true

require 'cuprum/rails/serializers/json/attributes_serializer'

require 'support/serializers'

module Spec::Support::Serializers
  class BookSerializer < Cuprum::Rails::Serializers::Json::AttributesSerializer
    attributes \
      :id,
      :title,
      :author,
      :series,
      :category

    attribute :published_at do |value|
      value&.iso8601
    end
  end
end
