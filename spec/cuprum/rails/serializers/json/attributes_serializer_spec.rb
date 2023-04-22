# frozen_string_literal: true

require 'cuprum/rails/serializers/json/attributes_serializer'

require 'support/book'
require 'support/examples/serializers/json/properties_serializer_examples'

RSpec.describe Cuprum::Rails::Serializers::Json::AttributesSerializer do
  include Spec::Support::Examples::Serializers::Json::PropertiesSerializerExamples # rubocop:disable Metrics/LineLength

  subject(:serializer) { described_class.new }

  shared_context 'when the serializer defines attributes' do
    before(:example) do
      Spec::Serializer.attribute(:fuel_type)
      Spec::Serializer.attribute(:fuel_quantity) { |value| "#{value} tonnes" }
    end
  end

  shared_context 'when the serializer subclass defines attributes' do
    include_context 'when the serializer defines attributes'

    before(:example) do
      Spec::Serializer.attribute(:cryogenic)
    end
  end

  describe '.new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  include_examples 'should implement the PropertiesSerializer methods'

  describe '.attribute' do
    shared_examples 'should serialize the attribute' do
      let(:property) do
        key = define_attribute

        described_class.properties[key]
      end
      let(:expected_mapping) do
        attribute_mapping || :itself.to_proc
      end
      let(:expected_serializer) do
        defined?(attribute_serializer) ? attribute_serializer : nil
      end

      it { expect(define_attribute).to be attribute_name.intern }

      it 'should define the attribute' do
        expect { define_attribute }
          .to change(described_class, :properties)
          .to have_key(attribute_name.intern)
      end

      it { expect(property.name).to be == attribute_name.to_s }

      it { expect(property.mapping).to be == expected_mapping }

      it { expect(property.scope).to be == attribute_name }

      it { expect(property.serializer).to be == expected_serializer }
    end

    let(:attribute_name)    { 'type' }
    let(:attribute_mapping) { nil }
    let(:options)           { {} }
    let(:error_class) do
      abstract_class =
        Cuprum::Rails::Serializers::Json::PropertiesSerializer

      abstract_class::AbstractSerializerError
    end
    let(:error_message) do
      "#{described_class.name} is an abstract class - create a subclass " \
        'to serialize properties'
    end

    def define_attribute
      described_class.attribute(attribute_name, **options, &attribute_mapping)
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:attribute)
        .with(1).argument
        .and_keywords(:serializer)
        .and_a_block
    end

    it 'should raise an exception' do
      expect { define_attribute }.to raise_error(error_class, error_message)
    end

    context 'with an abstract subclass' do
      include_context 'with a serializer class', described_class

      before(:example) do
        Spec::Serializer.instance_exec do
          @abstract_class = true
        end
      end

      it 'should raise an exception' do
        expect { define_attribute }.to raise_error(error_class, error_message)
      end
    end

    wrap_context 'with a serializer class' do
      it { expect { define_attribute }.not_to raise_error }

      describe 'with attribute_name: nil' do
        let(:attribute_name) { nil }
        let(:error_message) do
          "property name can't be blank"
        end

        it 'should raise an exception' do
          expect { define_attribute }
            .to raise_error(ArgumentError, error_message)
        end
      end

      describe 'with attribute_name: an Object' do
        let(:attribute_name) { Object.new }
        let(:error_message) do
          'property name is not a String or a Symbol'
        end

        it 'should raise an exception' do
          expect { define_attribute }
            .to raise_error(ArgumentError, error_message)
        end
      end

      describe 'with attribute_name: an empty String' do
        let(:attribute_name) { '' }
        let(:error_message) do
          "property name can't be blank"
        end

        it 'should raise an exception' do
          expect { define_attribute }
            .to raise_error(ArgumentError, error_message)
        end
      end

      describe 'with attribute_name: an empty Symbol' do
        let(:attribute_name) { :'' }
        let(:error_message) do
          "property name can't be blank"
        end

        it 'should raise an exception' do
          expect { define_attribute }
            .to raise_error(ArgumentError, error_message)
        end
      end

      describe 'with attribute_name: a String' do
        let(:attribute_name) { 'type' }

        include_examples 'should serialize the attribute'
      end

      describe 'with attribute_name: a Symbol' do
        let(:attribute_name) { :type }

        include_examples 'should serialize the attribute'
      end

      describe 'with serializer: nil' do
        let(:attribute_serializer) { nil }
        let(:options) do
          super().merge(serializer: attribute_serializer)
        end

        include_examples 'should serialize the attribute'
      end

      describe 'with serializer: an Object' do
        let(:attribute_serializer) { Object.new.freeze }
        let(:options) do
          super().merge(serializer: attribute_serializer)
        end
        let(:error_message) { 'serializer does not respond to #call' }

        it 'should raise an exception' do
          expect { define_attribute }
            .to raise_error(ArgumentError, error_message)
        end
      end

      describe 'with serializer: a Serializer instance' do
        let(:attribute_serializer) do
          Spec::Support::Serializers::BigDecimalSerializer.new
        end
        let(:options) { super().merge(serializer: attribute_serializer) }

        include_examples 'should serialize the attribute'
      end

      wrap_context 'when the serializer defines attributes' do
        include_examples 'should serialize the attribute'
      end
    end

    wrap_context 'with a serializer subclass' do
      it { expect { define_attribute }.not_to raise_error }

      include_examples 'should serialize the attribute'

      it 'should not change the parent class properties' do
        expect { define_attribute }
          .not_to change(Spec::Serializer, :properties)
      end

      # rubocop:disable RSpec/RepeatedExampleGroupBody
      wrap_context 'when the serializer defines attributes' do
        include_examples 'should serialize the attribute'
      end

      wrap_context 'when the serializer subclass defines attributes' do
        include_examples 'should serialize the attribute'
      end
      # rubocop:enable RSpec/RepeatedExampleGroupBody
    end
  end

  describe '.attributes' do
    let(:attribute_names)    { [] }
    let(:attribute_mappings) { {} }
    let(:error_class) do
      abstract_class =
        Cuprum::Rails::Serializers::Json::PropertiesSerializer

      abstract_class::AbstractSerializerError
    end
    let(:error_message) do
      "#{described_class.name} is an abstract class - create a subclass " \
        'to serialize properties'
    end

    def define_attributes
      described_class.attributes(*attribute_names, **attribute_mappings)
    end

    def ignore_exceptions
      yield
    rescue StandardError
      # Do nothing
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:attributes)
        .with_unlimited_arguments
        .and_arbitrary_keywords
    end

    it 'should raise an exception' do
      expect { define_attributes }.to raise_error(error_class, error_message)
    end

    context 'with an abstract subclass' do
      include_context 'with a serializer class', described_class

      before(:example) do
        Spec::Serializer.instance_exec do
          @abstract_class = true
        end
      end

      it 'should raise an exception' do
        expect { define_attributes }.to raise_error(error_class, error_message)
      end
    end

    wrap_context 'with a serializer class' do
      it { expect { define_attributes }.not_to raise_error }

      describe 'with no parameters' do
        it 'should not define any attributes' do
          expect { define_attributes }
            .not_to change(described_class, :properties)
        end
      end

      describe 'with attribute_name: nil' do
        let(:attribute_names) { [:fuel_type, nil, :fuel_quantity] }

        let(:error_message) do
          "property name can't be blank"
        end

        it 'should raise an exception' do
          expect { define_attributes }
            .to raise_error(ArgumentError, error_message)
        end

        it 'should not define any attributes' do
          expect { ignore_exceptions { define_attributes } }
            .not_to change(described_class, :properties)
        end
      end

      describe 'with attribute_name: an Object' do
        let(:attribute_names) do
          [:fuel_type, Object.new.freeze, :fuel_quantity]
        end

        let(:error_message) do
          'property name is not a String or a Symbol'
        end

        it 'should raise an exception' do
          expect { define_attributes }
            .to raise_error(ArgumentError, error_message)
        end

        it 'should not define any attributes' do
          expect { ignore_exceptions { define_attributes } }
            .not_to change(described_class, :properties)
        end
      end

      describe 'with attribute_name: an empty String' do
        let(:attribute_names) { ['fuel_type', '', 'fuel_quantity'] }

        let(:error_message) do
          "property name can't be blank"
        end

        it 'should raise an exception' do
          expect { define_attributes }
            .to raise_error(ArgumentError, error_message)
        end

        it 'should not define any attributes' do
          expect { ignore_exceptions { define_attributes } }
            .not_to change(described_class, :properties)
        end
      end

      describe 'with attribute_name: an empty Symbol' do
        let(:attribute_names) { [:fuel_type, :'', :fuel_quantity] }

        let(:error_message) do
          "property name can't be blank"
        end

        it 'should raise an exception' do
          expect { define_attributes }
            .to raise_error(ArgumentError, error_message)
        end

        it 'should not define any attributes' do
          expect { ignore_exceptions { define_attributes } }
            .not_to change(described_class, :properties)
        end
      end

      describe 'with attribute_mapping key: nil' do
        let(:attribute_mappings) do
          {
            fuel_type:     :itself,
            nil         => :itself,
            fuel_quantity: :itself
          }
        end

        let(:error_message) do
          "property name can't be blank"
        end

        it 'should raise an exception' do
          expect { define_attributes }
            .to raise_error(ArgumentError, error_message)
        end

        it 'should not define any attributes' do
          expect { ignore_exceptions { define_attributes } }
            .not_to change(described_class, :properties)
        end
      end

      describe 'with attribute_mapping key: an Object' do
        let(:attribute_mappings) do
          {
            fuel_type:           :itself,
            Object.new.freeze => :itself,
            fuel_quantity:       :itself
          }
        end

        let(:error_message) do
          'property name is not a String or a Symbol'
        end

        it 'should raise an exception' do
          expect { define_attributes }
            .to raise_error(ArgumentError, error_message)
        end

        it 'should not define any attributes' do
          expect { ignore_exceptions { define_attributes } }
            .not_to change(described_class, :properties)
        end
      end

      describe 'with attribute_mapping key: an empty String' do
        let(:attribute_mappings) do
          {
            'fuel_type'     => :itself,
            ''              => :itself,
            'fuel_quantity' => :itself
          }
        end

        let(:error_message) do
          "property name can't be blank"
        end

        it 'should raise an exception' do
          expect { define_attributes }
            .to raise_error(ArgumentError, error_message)
        end

        it 'should not define any attributes' do
          expect { ignore_exceptions { define_attributes } }
            .not_to change(described_class, :properties)
        end
      end

      describe 'with attribute_mapping key: an empty Symbol' do
        let(:attribute_mappings) do
          {
            fuel_type:     :itself,
            '':            :itself,
            fuel_quantity: :itself
          }
        end

        let(:error_message) do
          "property name can't be blank"
        end

        it 'should raise an exception' do
          expect { define_attributes }
            .to raise_error(ArgumentError, error_message)
        end

        it 'should not define any attributes' do
          expect { ignore_exceptions { define_attributes } }
            .not_to change(described_class, :properties)
        end
      end

      describe 'with attribute_mapping value: nil' do
        let(:attribute_mappings) do
          {
            fuel_type:     :itself,
            fuel_quantity: nil
          }
        end

        let(:error_message) do
          'property mapping must respond to #to_proc'
        end

        it 'should raise an exception' do
          expect { define_attributes }
            .to raise_error(ArgumentError, error_message)
        end

        it 'should not define any attributes' do
          expect { ignore_exceptions { define_attributes } }
            .not_to change(described_class, :properties)
        end
      end

      describe 'with attribute_mapping value: an Object' do
        let(:attribute_mappings) do
          {
            fuel_type:     :itself,
            fuel_quantity: Object.new.freeze
          }
        end

        let(:error_message) do
          'property mapping must respond to #to_proc'
        end

        it 'should raise an exception' do
          expect { define_attributes }
            .to raise_error(ArgumentError, error_message)
        end

        it 'should not define any attributes' do
          expect { ignore_exceptions { define_attributes } }
            .not_to change(described_class, :properties)
        end
      end

      describe 'with attribute names: Strings' do
        let(:attribute_names) { %w[name type mass] }

        it 'should define the attributes' do # rubocop:disable RSpec/ExampleLength
          expect { define_attributes }
            .to change(described_class, :properties)
            .to(
              satisfy do |properties|
                attribute_names.all? { |name| properties.key?(name.intern) }
              end
            )
        end

        it 'should set the property mappings', :aggregate_failures do
          define_attributes

          attribute_names.each do |name|
            property = described_class.properties[name.intern]

            expect(property.mapping).to be == :itself.to_proc
          end
        end

        it 'should set the property names', :aggregate_failures do
          define_attributes

          attribute_names.each do |name|
            property = described_class.properties[name.intern]

            expect(property.name).to be == name
          end
        end

        it 'should set the property scopes', :aggregate_failures do
          define_attributes

          attribute_names.each do |name|
            property = described_class.properties[name.intern]

            expect(property.scope).to be == name
          end
        end

        it 'should set the property serializers', :aggregate_failures do
          define_attributes

          attribute_names.each do |name|
            property = described_class.properties[name.intern]

            expect(property.serializer).to be nil
          end
        end
      end

      describe 'with attribute names: Symbols' do
        let(:attribute_names) { %i[name type mass] }

        it 'should define the attributes' do # rubocop:disable RSpec/ExampleLength
          expect { define_attributes }
            .to change(described_class, :properties)
            .to(
              satisfy do |properties|
                attribute_names.all? { |name| properties.key?(name) }
              end
            )
        end

        it 'should set the property mappings', :aggregate_failures do
          define_attributes

          attribute_names.each do |name|
            property = described_class.properties[name]

            expect(property.mapping).to be == :itself.to_proc
          end
        end

        it 'should set the property names', :aggregate_failures do
          define_attributes

          attribute_names.each do |name|
            property = described_class.properties[name]

            expect(property.name).to be == name.to_s
          end
        end

        it 'should set the property scopes', :aggregate_failures do
          define_attributes

          attribute_names.each do |name|
            property = described_class.properties[name]

            expect(property.scope).to be == name
          end
        end

        it 'should set the property serializers', :aggregate_failures do
          define_attributes

          attribute_names.each do |name|
            property = described_class.properties[name]

            expect(property.serializer).to be nil
          end
        end
      end

      describe 'with attribute mappings: with String keys' do
        let(:quantity_mapping) { ->(value) { "#{value} tonnes" } }
        let(:attribute_mappings) do
          {
            'fuel_type'     => :to_s,
            'fuel_quantity' => quantity_mapping
          }
        end

        it 'should define the attributes' do # rubocop:disable RSpec/ExampleLength
          expect { define_attributes }
            .to change(described_class, :properties)
            .to(
              satisfy do |properties|
                attribute_mappings.each_key.all? do |name|
                  properties.key?(name.intern)
                end
              end
            )
        end

        it 'should set the property mappings', :aggregate_failures do
          define_attributes

          property = described_class.properties[:fuel_type]
          expect(property.mapping).to be == :to_s.to_proc

          property = described_class.properties[:fuel_quantity]
          expect(property.mapping).to be == quantity_mapping
        end

        it 'should set the property names', :aggregate_failures do
          define_attributes

          attribute_mappings.each_key do |name|
            property = described_class.properties[name.intern]

            expect(property.name).to be == name
          end
        end

        it 'should set the property scopes', :aggregate_failures do
          define_attributes

          attribute_mappings.each_key do |name|
            property = described_class.properties[name.intern]

            expect(property.scope).to be == name
          end
        end

        it 'should set the property serializers', :aggregate_failures do
          define_attributes

          attribute_mappings.each_key do |name|
            property = described_class.properties[name.intern]

            expect(property.serializer).to be nil
          end
        end
      end

      describe 'with attribute mappings: with Symbol keys' do
        let(:quantity_mapping) { ->(value) { "#{value} tonnes" } }
        let(:attribute_mappings) do
          {
            fuel_type:     :to_s,
            fuel_quantity: quantity_mapping
          }
        end

        it 'should define the attributes' do # rubocop:disable RSpec/ExampleLength
          expect { define_attributes }
            .to change(described_class, :properties)
            .to(
              satisfy do |properties|
                attribute_mappings.each_key.all? do |name|
                  properties.key?(name)
                end
              end
            )
        end

        it 'should set the property mappings', :aggregate_failures do
          define_attributes

          property = described_class.properties[:fuel_type]
          expect(property.mapping).to be == :to_s.to_proc

          property = described_class.properties[:fuel_quantity]
          expect(property.mapping).to be == quantity_mapping
        end

        it 'should set the property names', :aggregate_failures do
          define_attributes

          attribute_mappings.each_key do |name|
            property = described_class.properties[name]

            expect(property.name).to be == name.to_s
          end
        end

        it 'should set the property scopes', :aggregate_failures do
          define_attributes

          attribute_mappings.each_key do |name|
            property = described_class.properties[name]

            expect(property.scope).to be == name
          end
        end

        it 'should set the property serializers', :aggregate_failures do
          define_attributes

          attribute_mappings.each_key do |name|
            property = described_class.properties[name]

            expect(property.serializer).to be nil
          end
        end
      end

      describe 'with attribute names and mappings' do
        let(:quantity_mapping) { ->(value) { "#{value} tonnes" } }
        let(:attribute_names)  { %i[name type mass] }
        let(:attribute_mappings) do
          {
            fuel_type:     :to_s,
            fuel_quantity: quantity_mapping
          }
        end

        it 'should define the attributes' do # rubocop:disable RSpec/ExampleLength
          expect { define_attributes }
            .to change(described_class, :properties)
            .to(
              satisfy do |properties|
                attribute_names.all? { |name| properties.key?(name) } &&
                  attribute_mappings.each_key.all? do |name|
                    properties.key?(name)
                  end
              end
            )
        end
      end
    end
  end

  describe '#call' do
    shared_examples 'should serialize the properties' do
      it 'should serialize the properties' do
        expect(serializer.call(object, context: context))
          .to be == expected
      end
    end

    let(:object) do
      Spec::Part.new(
        name:          'Small Fuel Tank',
        type:          'propellant_tank',
        mass:          10,
        cost:          BigDecimal('100.0'),
        fuel_type:     'helium_3',
        fuel_quantity: 5,
        cryogenic:     true,
        inspected_at:  Date.new(1977, 5, 25)
      )
    end
    let(:serializers) do
      Cuprum::Rails::Serializers::Json.default_serializers
    end
    let(:context) do
      Cuprum::Rails::Serializers::Context.new(serializers: serializers)
    end
    let(:expected) { {} }

    example_class 'Spec::Part', Struct.new(
      :name,
      :type,
      :mass,
      :cost,
      :fuel_type,
      :fuel_quantity,
      :cryogenic,
      :inspected_at,
      keyword_init: true
    )

    wrap_context 'with a serializer class' do
      wrap_context 'when the serializer defines attributes' do
        let(:expected) do
          {
            'fuel_type'     => object[:fuel_type],
            'fuel_quantity' => "#{object[:fuel_quantity]} tonnes"
          }
        end

        include_examples 'should serialize the properties'

        describe 'with nil' do
          it { expect(serializer.call(nil, context: context)).to be nil }
        end

        describe 'with a hash object' do
          let(:object) { super().to_h }

          include_examples 'should serialize the properties'
        end
      end

      context 'when the serializer defines attributes and properties' do
        include_context 'when the serializer defines attributes'
        include_context 'when the serializer defines properties'

        let(:expected) do
          checksum = Digest::MD5.hexdigest(object[:name])

          {
            'name'          => object[:name],
            'mass'          => object[:mass],
            'cost'          => object[:cost].to_s,
            'checksum'      => checksum,
            'fuel_type'     => object[:fuel_type],
            'fuel_quantity' => "#{object[:fuel_quantity]} tonnes"
          }
        end

        include_examples 'should serialize the properties'

        describe 'with nil' do
          it { expect(serializer.call(nil, context: context)).to be nil }
        end

        describe 'with a hash object' do
          let(:object) { super().to_h }

          include_examples 'should serialize the properties'
        end
      end
    end

    wrap_context 'with a serializer subclass' do
      wrap_context 'when the serializer defines attributes' do
        let(:expected) do
          {
            'fuel_type'     => object[:fuel_type],
            'fuel_quantity' => "#{object[:fuel_quantity]} tonnes"
          }
        end

        include_examples 'should serialize the properties'

        describe 'with nil' do
          it { expect(serializer.call(nil, context: context)).to be nil }
        end

        describe 'with a hash object' do
          let(:object) { super().to_h }

          include_examples 'should serialize the properties'
        end
      end

      context 'when the serializer defines attributes and properties' do
        include_context 'when the serializer defines attributes'
        include_context 'when the serializer defines properties'

        let(:expected) do
          checksum = Digest::MD5.hexdigest(object[:name])

          {
            'name'          => object[:name],
            'mass'          => object[:mass],
            'cost'          => object[:cost].to_s,
            'checksum'      => checksum,
            'fuel_type'     => object[:fuel_type],
            'fuel_quantity' => "#{object[:fuel_quantity]} tonnes"
          }
        end

        include_examples 'should serialize the properties'

        describe 'with nil' do
          it { expect(serializer.call(nil, context: context)).to be nil }
        end

        describe 'with a hash object' do
          let(:object) { super().to_h }

          include_examples 'should serialize the properties'
        end
      end

      wrap_context 'when the serializer subclass defines attributes' do
        let(:expected) do
          {
            'fuel_type'     => object[:fuel_type],
            'fuel_quantity' => "#{object[:fuel_quantity]} tonnes",
            'cryogenic'     => true
          }
        end

        include_examples 'should serialize the properties'

        describe 'with nil' do
          it { expect(serializer.call(nil, context: context)).to be nil }
        end

        describe 'with a hash object' do
          let(:object) { super().to_h }

          include_examples 'should serialize the properties'
        end
      end

      context 'when the serializer subclass defines attributes and properties' \
      do
        include_context 'when the serializer subclass defines attributes'
        include_context 'when the serializer subclass defines properties'

        let(:expected) do
          checksum = Digest::MD5.hexdigest(object[:name])

          {
            'name'          => object[:name],
            'mass'          => object[:mass],
            'cost'          => object[:cost].to_s,
            'checksum'      => checksum,
            'inspected_at'  => object[:inspected_at].iso8601,
            'fuel_type'     => object[:fuel_type],
            'fuel_quantity' => "#{object[:fuel_quantity]} tonnes",
            'cryogenic'     => true
          }
        end

        include_examples 'should serialize the properties'

        describe 'with nil' do
          it { expect(serializer.call(nil, context: context)).to be nil }
        end

        describe 'with a hash object' do
          let(:object) { super().to_h }

          include_examples 'should serialize the properties'
        end
      end
    end
  end
end
