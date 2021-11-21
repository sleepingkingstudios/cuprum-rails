# frozen_string_literal: true

require 'cuprum/rails/rspec/serializers_contracts'

require 'support/book'
require 'support/serializers/book_serializer'

# @note Integration spec for
#   Cuprum::Rails::Serializers::Json::AttributesSerializer.
RSpec.describe Spec::Support::Serializers::BookSerializer do
  let(:serializer) { described_class.new }

  describe '#call' do
    let(:object) do
      Book.new(
        title:        'Gideon the Ninth',
        author:       'Tamsyn Muir',
        series:       'The Locked Tomb',
        category:     'Science Fiction and Fantasy',
        published_at: DateTime.new(2019, 9, 10)
      )
    end

    include_contract \
      Cuprum::Rails::RSpec::SerializersContracts::SHOULD_SERIALIZE_ATTRIBUTES,
      :id,
      :title,
      :author,
      :series,
      :category,
      published_at: -> { object.published_at.iso8601 }
  end
end
