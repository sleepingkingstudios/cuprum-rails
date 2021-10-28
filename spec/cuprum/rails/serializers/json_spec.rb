# frozen_string_literal: true

require 'cuprum/rails/serializers/json'

RSpec.describe Cuprum::Rails::Serializers::Json do
  describe '.default_serializers' do
    let(:default_serializers) { described_class.default_serializers }
    let(:expected_keys) do
      [
        Array,
        Cuprum::Error,
        FalseClass,
        Float,
        Hash,
        Integer,
        NilClass,
        String,
        TrueClass
      ]
    end

    include_examples 'should define class reader',
      :default_serializers,
      -> { an_instance_of(Hash) }

    it 'should define the default serializers' do
      expect(default_serializers.keys).to contain_exactly(*expected_keys)
    end

    it 'should define the Array serializer' do
      expect(default_serializers[Array])
        .to be_a Cuprum::Rails::Serializers::Json::ArraySerializer
    end

    it 'should define the Cupurm::Error serializer' do
      expect(default_serializers[Cuprum::Error])
        .to be_a Cuprum::Rails::Serializers::Json::ErrorSerializer
    end

    it 'should define the FalseClass serializer' do
      expect(default_serializers[FalseClass])
        .to be_a Cuprum::Rails::Serializers::Json::IdentitySerializer
    end

    it 'should define the Float serializer' do
      expect(default_serializers[Float])
        .to be_a Cuprum::Rails::Serializers::Json::IdentitySerializer
    end

    it 'should define the Hash serializer' do
      expect(default_serializers[Hash])
        .to be_a Cuprum::Rails::Serializers::Json::HashSerializer
    end

    it 'should define the Integer serializer' do
      expect(default_serializers[Integer])
        .to be_a Cuprum::Rails::Serializers::Json::IdentitySerializer
    end

    it 'should define the NilClass serializer' do
      expect(default_serializers[NilClass])
        .to be_a Cuprum::Rails::Serializers::Json::IdentitySerializer
    end

    it 'should define the String serializer' do
      expect(default_serializers[String])
        .to be_a Cuprum::Rails::Serializers::Json::IdentitySerializer
    end

    it 'should define the TrueClass serializer' do
      expect(default_serializers[TrueClass])
        .to be_a Cuprum::Rails::Serializers::Json::IdentitySerializer
    end
  end
end
