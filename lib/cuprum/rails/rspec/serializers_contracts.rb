# frozen_string_literal: true

require 'rspec/sleeping_king_studios/contract'

require 'cuprum/rails/rspec'

module Cuprum::Rails::RSpec
  # Namespace for contracts that specify serialization behavior.
  module SerializersContracts
    # Contract specifying that a serializer serializes the expected properties.
    class ShouldSerializeAttributesContract
      extend RSpec::SleepingKingStudios::Contract

      # @method apply(example_group, *attribute_names, **attribute_values)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #   @param attribute_names [Array] The names of the attributes to
      #     serialize. The value for each attribute should match the value of
      #     the attribute on the original object.
      #   @param attribute_values [Hash] The names and values of attributes to
      #     serialize. The value of the serialized attribute should match the
      #     given value.

      contract do |*attribute_names, **attribute_values| # rubocop:disable Metrics/BlockLength
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
            .to_h do |attr_name|
              [attr_name, context.serialize(object.send(attr_name))]
            end # rubocop:disable Style/MultilineBlockChain
            .merge(attribute_values)
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

        attribute_values.each do |attr_name, attr_value|
          it "should serialize the #{attr_name.inspect} attribute" do
            attr_value = instance_exec(&attr_value) if attr_value.is_a?(Proc)

            expect(serialized[attr_name.to_s]).to be == attr_value
          end
        end
      end
    end
  end
end
