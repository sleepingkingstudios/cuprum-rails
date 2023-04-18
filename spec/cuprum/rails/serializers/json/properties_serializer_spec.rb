# frozen_string_literal: true

require 'cuprum/rails/serializers/json/properties_serializer'

require 'support/examples/serializers/json_serializer_examples'

RSpec.describe Cuprum::Rails::Serializers::Json::PropertiesSerializer do
  include Spec::Support::Examples::Serializers::JsonSerializerExamples

  subject(:serializer) { described_class.new }

  describe '::AbstractSerializerError' do
    it 'should define the error class' do
      expect(described_class)
        .to define_constant(:AbstractSerializerError)
        .with_value(an_instance_of(Class).and(be < StandardError))
    end
  end

  describe '.new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  include_examples 'should implement the PropertiesSerializer methods'
end
