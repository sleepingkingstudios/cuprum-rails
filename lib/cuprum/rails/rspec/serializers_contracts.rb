# frozen_string_literal: true

require 'cuprum/rails/rspec'

module Cuprum::Rails::RSpec
  # Namespace for contracts that specify serialization behavior.
  module SerializersContracts
    SHOULD_SERIALIZE_ATTRIBUTES = lambda do |*attribute_names, **attributes| # rubocop:disable Metrics/BlockLength
      let(:serializers) do
        return super() if defined?(super())

        Cuprum::Rails::Serializers::Json.default_serializers
      end
      let(:context) do
        return super() if defined?(super())

        Cuprum::Rails::Serializers::Context.new(serializers: serializers)
      end
      let(:expected_attributes) do
        tools = SleepingKingStudios::Tools::Toolbelt.instance

        attribute_names
          .map do |attr_name|
            [attr_name, context.serialize(object.send(attr_name))]
          end # rubocop:disable Style/MultilineBlockChain
          .to_h
          .merge(attributes)
          .yield_self { |hsh| tools.hash_tools.convert_keys_to_strings(hsh) }
      end
      let(:serialized) { serializer.call(object, context: context) }

      it 'should serialize the expected attributes' do
        expect(serialized.keys).to contain_exactly(*expected_attributes.keys)
      end

      attribute_names.each do |attr_name|
        it "should serialize the #{attr_name.inspect} attribute" do
          expect(serialized[attr_name.to_s])
            .to be == expected_attributes[attr_name.to_s]
        end
      end

      attributes.each do |attr_name, attr_value|
        it "should serialize the #{attr_name.inspect} attribute" do
          attr_value = instance_exec(&attr_value) if attr_value.is_a?(Proc)

          expect(serialized[attr_name.to_s]).to be == attr_value
        end
      end
    end
  end
end
