# frozen_string_literal: true

require 'bigdecimal'
require 'digest'

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'support/examples/serializers/json'
require 'support/serializers/big_decimal_serializer'

module Spec::Support::Examples::Serializers::Json
  module PropertiesSerializerExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'with a serializer class' do
      let(:described_class) { Spec::Serializer }

      example_class 'Spec::Serializer', described_class
    end

    shared_context 'with a serializer subclass' do
      include_context 'with a serializer class'

      let(:described_class) { Spec::SerializerSubclass }

      example_class 'Spec::SerializerSubclass', 'Spec::Serializer'
    end

    shared_context 'when the serializer defines properties' do
      before(:example) do
        Spec::Serializer.property(:name) { |object| object[:name] }
        Spec::Serializer.property(:mass, scope: :mass)
        Spec::Serializer.property(
          :cost,
          serializer: Spec::Support::Serializers::BigDecimalSerializer.new
        ) { |object| object[:cost] }
        Spec::Serializer.property(:checksum) do |object|
          Digest::MD5.hexdigest(object[:name])
        end
      end
    end

    shared_context 'when the serializer subclass defines properties' do
      include_context 'when the serializer defines properties'

      before(:example) do
        described_class.property(:inspected_at, scope: :inspected_at, &:iso8601)
      end
    end

    shared_examples 'should implement the PropertiesSerializer methods' do
      describe '.property' do
        shared_examples 'should require at least one optional parameter' do
          let(:error_message) do
            'must provide a scope, a serializer, or a mapping block'
          end

          it 'should raise an exception' do
            expect { define_property }
              .to raise_error(ArgumentError, error_message)
          end
        end

        shared_examples 'should serialize the property' do
          let(:property) do
            key = define_property

            described_class.properties[key]
          end
          let(:expected_mapping) do
            property_mapping || :itself.to_proc
          end
          let(:expected_scope) do
            defined?(property_scope) ? property_scope : nil
          end
          let(:expected_serializer) do
            defined?(property_serializer) ? property_serializer : nil
          end

          it { expect(define_property).to be property_name.intern }

          it 'should define the property' do
            expect { define_property }
              .to change(described_class, :properties)
              .to have_key(property_name.intern)
          end

          it { expect(property.name).to be == property_name.to_s }

          it { expect(property.mapping).to be == expected_mapping }

          it { expect(property.scope).to be == expected_scope }

          it { expect(property.serializer).to be == expected_serializer }
        end

        let(:property_name)    { 'checksum' }
        let(:property_mapping) { nil }
        let(:options)          { {} }
        let(:error_class) do
          abstract_class =
            Cuprum::Rails::Serializers::Json::PropertiesSerializer

          abstract_class::AbstractSerializerError
        end
        let(:error_message) do
          "#{described_class.name} is an abstract class - create a subclass " \
            'to serialize properties'
        end

        def define_property
          described_class.property(property_name, **options, &property_mapping)
        end

        it 'should define the class method' do
          expect(described_class)
            .to respond_to(:property)
            .with(1).argument
            .and_keywords(:serializer, :scope)
            .and_a_block
        end

        it 'should raise an exception' do
          expect { define_property }.to raise_error(error_class, error_message)
        end

        context 'with an abstract subclass' do
          include_context 'with a serializer class', described_class

          before(:example) do
            Spec::Serializer.instance_exec do
              @abstract_class = true
            end
          end

          it 'should raise an exception' do
            expect { define_property }
              .to raise_error(error_class, error_message)
          end
        end

        wrap_context 'with a serializer class' do
          include_examples 'should require at least one optional parameter'

          describe 'with property_name: nil' do
            let(:property_name) { nil }
            let(:error_message) do
              "property name can't be blank"
            end

            it 'should raise an exception' do
              expect { define_property }
                .to raise_error(ArgumentError, error_message)
            end
          end

          describe 'with property_name: an Object' do
            let(:property_name) { Object.new }
            let(:error_message) do
              'property name is not a String or a Symbol'
            end

            it 'should raise an exception' do
              expect { define_property }
                .to raise_error(ArgumentError, error_message)
            end
          end

          describe 'with property_name: an empty String' do
            let(:property_name) { '' }
            let(:error_message) do
              "property name can't be blank"
            end

            it 'should raise an exception' do
              expect { define_property }
                .to raise_error(ArgumentError, error_message)
            end
          end

          describe 'with property_name: an empty Symbol' do
            let(:property_name) { :'' }
            let(:error_message) do
              "property name can't be blank"
            end

            it 'should raise an exception' do
              expect { define_property }
                .to raise_error(ArgumentError, error_message)
            end
          end

          describe 'with property_name: a String' do
            let(:property_name) { 'checksum' }

            include_examples 'should require at least one optional parameter'

            context 'with a block' do
              let(:property_mapping) do
                ->(object) { Digest::SHA256.hexdigest(object.name) }
              end

              include_examples 'should serialize the property'
            end
          end

          describe 'with property_name: a Symbol' do
            let(:property_name) { :checksum }

            include_examples 'should require at least one optional parameter'

            context 'with a block' do
              let(:property_mapping) do
                ->(object) { Digest::SHA256.hexdigest(object.name) }
              end

              include_examples 'should serialize the property'
            end
          end

          describe 'with scope: nil' do
            let(:property_scope) { nil }
            let(:options)        { super().merge(scope: property_scope) }

            include_examples 'should require at least one optional parameter'

            context 'with a block' do
              let(:property_mapping) do
                ->(object) { Digest::SHA256.hexdigest(object.name) }
              end

              include_examples 'should serialize the property'
            end
          end

          describe 'with scope: an Object' do
            let(:property_scope) { Object.new }
            let(:options)        { super().merge(scope: property_scope) }
            let(:error_message) do
              'scope is not a String, a Symbol, or an Array of Strings or ' \
                'Symbols'
            end

            it 'should raise an exception' do
              expect { define_property }
                .to raise_error(ArgumentError, error_message)
            end
          end

          describe 'with scope: a String' do
            let(:property_mapping) do
              ->(object) { Digest::MD5.hexdigest(object) }
            end
            let(:property_scope) { 'name' }
            let(:options)        { super().merge(scope: property_scope) }

            include_examples 'should serialize the property'
          end

          describe 'with scope: a Symbol' do
            let(:property_mapping) do
              ->(object) { Digest::MD5.hexdigest(object) }
            end
            let(:property_scope) { :name }
            let(:options)        { super().merge(scope: property_scope) }

            include_examples 'should serialize the property'
          end

          describe 'with scope: an empty Array' do
            let(:property_scope) { [] }
            let(:options)        { super().merge(scope: property_scope) }

            include_examples 'should serialize the property'
          end

          describe 'with scope: an Array containing nil' do
            let(:property_scope) { [nil] }
            let(:options)        { super().merge(scope: property_scope) }
            let(:error_message) do
              'scope is not a String, a Symbol, or an Array of Strings or ' \
                'Symbols'
            end

            it 'should raise an exception' do
              expect { define_property }
                .to raise_error(ArgumentError, error_message)
            end
          end

          describe 'with scope: an Array containing an Object' do
            let(:property_scope) { [Object.new.freeze] }
            let(:options)        { super().merge(scope: property_scope) }
            let(:error_message) do
              'scope is not a String, a Symbol, or an Array of Strings or ' \
                'Symbols'
            end

            it 'should raise an exception' do
              expect { define_property }
                .to raise_error(ArgumentError, error_message)
            end
          end

          describe 'with scope: an Array containing an empty String' do
            let(:property_scope) { [''] }
            let(:options)        { super().merge(scope: property_scope) }
            let(:error_message)  { "scope item at 0 can't be blank" }

            it 'should raise an exception' do
              expect { define_property }
                .to raise_error(ArgumentError, error_message)
            end
          end

          describe 'with scope: an Array containing an empty Symbol' do
            let(:property_scope) { [:''] }
            let(:options)        { super().merge(scope: property_scope) }
            let(:error_message)  { "scope item at 0 can't be blank" }

            it 'should raise an exception' do
              expect { define_property }
                .to raise_error(ArgumentError, error_message)
            end
          end

          describe 'with scope: an Array containing valid Strings' do
            let(:property_scope) { %w[factory name] }
            let(:options)        { super().merge(scope: property_scope) }

            include_examples 'should serialize the property'
          end

          describe 'with scope: an Array containing valid Symbols' do
            let(:property_scope) { %i[factory name] }
            let(:options)        { super().merge(scope: property_scope) }

            include_examples 'should serialize the property'
          end

          describe 'with serializer: nil' do
            let(:property_serializer) { nil }
            let(:options) do
              super().merge(serializer: property_serializer)
            end

            include_examples 'should require at least one optional parameter'

            context 'with a block' do
              let(:property_mapping) do
                ->(object) { Digest::SHA256.hexdigest(object.name) }
              end

              include_examples 'should serialize the property'
            end
          end

          describe 'with serializer: an Object' do
            let(:property_serializer) { Object.new.freeze }
            let(:options) do
              super().merge(serializer: property_serializer)
            end
            let(:error_message) { 'serializer does not respond to #call' }

            it 'should raise an exception' do
              expect { define_property }
                .to raise_error(ArgumentError, error_message)
            end
          end

          describe 'with serializer: a Serializer instance' do
            let(:property_serializer) do
              Spec::Support::Serializers::BigDecimalSerializer.new
            end
            let(:options) { super().merge(serializer: property_serializer) }

            include_examples 'should serialize the property'
          end

          wrap_context 'when the serializer defines properties' do
            include_examples 'should require at least one optional parameter'

            context 'with a block' do
              let(:property_mapping) do
                ->(object) { Digest::SHA256.hexdigest(object.name) }
              end

              include_examples 'should serialize the property'
            end
          end
        end

        wrap_context 'with a serializer subclass' do
          include_examples 'should require at least one optional parameter'

          context 'with a block' do
            let(:property_mapping) do
              ->(object) { Digest::SHA256.hexdigest(object.name) }
            end

            include_examples 'should serialize the property'

            it 'should not change the parent class properties' do
              expect { define_property }
                .not_to change(Spec::Serializer, :properties)
            end
          end

          # rubocop:disable RSpec/RepeatedExampleGroupBody
          wrap_context 'when the serializer defines properties' do
            include_examples 'should require at least one optional parameter'

            context 'with a block' do
              let(:property_mapping) do
                ->(object) { Digest::SHA256.hexdigest(object.name) }
              end

              include_examples 'should serialize the property'
            end
          end

          wrap_context 'when the serializer subclass defines properties' do
            include_examples 'should require at least one optional parameter'

            context 'with a block' do
              let(:property_mapping) do
                ->(object) { Digest::SHA256.hexdigest(object.name) }
              end

              include_examples 'should serialize the property'
            end
          end
          # rubocop:enable RSpec/RepeatedExampleGroupBody
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
            name:         'Rocket Engine',
            mass:         10,
            cost:         BigDecimal('100.0'),
            inspected_at: Date.new(1977, 5, 25),
            factory:      Spec::Factory.new('Terminal Space Center')
          )
        end
        let(:serializers) do
          Cuprum::Rails::Serializers::Json.default_serializers
        end
        let(:context) do
          Cuprum::Rails::Serializers::Context.new(serializers: serializers)
        end
        let(:expected) { {} }

        example_class 'Spec::Factory', Struct.new(:name)

        example_class 'Spec::Part', Struct.new(
          :name,
          :mass,
          :cost,
          :inspected_at,
          :factory,
          keyword_init: true
        )

        it 'should define the method' do
          expect(serializer)
            .to respond_to(:call)
            .with(1).argument
            .and_keywords(:context)
        end

        include_examples 'should serialize the properties'

        describe 'with nil' do
          it { expect(serializer.call(nil, context: context)).to be nil }
        end

        wrap_context 'with a serializer class' do
          include_examples 'should serialize the properties'

          describe 'with nil' do
            it { expect(serializer.call(nil, context: context)).to be nil }
          end

          describe 'with a hash object' do
            let(:object) { super().to_h }

            include_examples 'should serialize the properties'
          end

          wrap_context 'when the serializer defines properties' do
            let(:expected) do
              checksum = Digest::MD5.hexdigest(object[:name])

              {
                'name'     => object[:name],
                'mass'     => object[:mass],
                'cost'     => object[:cost].to_s,
                'checksum' => checksum
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

          context 'when the serializer defines a property with Array scope' do
            let(:expected) { { 'factory_name' => object[:factory].name } }

            before(:example) do
              described_class.property(
                :factory_name,
                scope: %i[factory name]
              )
            end

            include_examples 'should serialize the properties'

            describe 'with a hash object' do
              let(:object) { super().to_h }

              include_examples 'should serialize the properties'
            end
          end

          context 'when the serializer defines a child property' do
            let(:object) do
              Spec::Employee.new(
                name:       'Alan Bradley',
                supervisor: Spec::Employee.new(name: 'Ed Dillinger')
              )
            end
            let(:expected) do
              {
                'name'       => 'Alan Bradley',
                'supervisor' => {
                  'name'       => 'Ed Dillinger',
                  'supervisor' => nil
                }
              }
            end

            example_class 'Spec::Employee',
              Struct.new(:name, :supervisor, keyword_init: true)

            before(:example) do
              described_class.property(:name, scope: :name)
              described_class.property(
                :supervisor,
                scope:      :supervisor,
                serializer: described_class.new
              )
            end

            include_examples 'should serialize the properties'
          end
        end

        wrap_context 'with a serializer subclass' do
          include_examples 'should serialize the properties'

          describe 'with a hash object' do
            let(:object) { super().to_h }

            include_examples 'should serialize the properties'
          end

          wrap_context 'when the serializer defines properties' do
            let(:expected) do
              checksum = Digest::MD5.hexdigest(object[:name])

              {
                'name'     => object[:name],
                'mass'     => object[:mass],
                'cost'     => object[:cost].to_s,
                'checksum' => checksum
              }
            end

            include_examples 'should serialize the properties'

            describe 'with a hash object' do
              let(:object) { super().to_h }

              include_examples 'should serialize the properties'
            end
          end

          wrap_context 'when the serializer subclass defines properties' do
            let(:expected) do
              checksum = Digest::MD5.hexdigest(object[:name])

              {
                'name'         => object[:name],
                'mass'         => object[:mass],
                'cost'         => object[:cost].to_s,
                'checksum'     => checksum,
                'inspected_at' => object[:inspected_at].iso8601
              }
            end

            include_examples 'should serialize the properties'

            describe 'with a hash object' do
              let(:object) { super().to_h }

              include_examples 'should serialize the properties'
            end
          end
        end
      end
    end
  end
end
