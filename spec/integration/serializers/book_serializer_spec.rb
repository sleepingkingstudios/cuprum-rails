# frozen_string_literal: true

require 'cuprum/rails/rspec/contracts/serializers_contracts'

require 'support/book'
require 'support/serializers/book_serializer'

# @note Integration spec for
#   Cuprum::Rails::Serializers::Json::AttributesSerializer.
RSpec.describe Spec::Support::Serializers::BookSerializer do
  include Cuprum::Rails::RSpec::Contracts::SerializersContracts

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

    include_contract 'should serialize attributes',
      :id,
      :title,
      :author,
      :series,
      :category,
      published_at: -> { object.published_at.iso8601 }
  end
end
