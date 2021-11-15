# frozen_string_literal: true

require 'cuprum/rails/serializers/json/attributes_serializer'

require 'support/book'

RSpec.describe Cuprum::Rails::Serializers::Json::AttributesSerializer do
  shared_context 'with a serializer class' do
    let(:described_class) { Spec::Serializer }

    example_class 'Spec::Serializer',
      Cuprum::Rails::Serializers::Json::AttributesSerializer # rubocop:disable RSpec/DescribedClass
  end

  shared_context 'with a serializer subclass' do
    include_context 'with a serializer class'

    let(:described_class) { Spec::SerializerSubclass }

    example_class 'Spec::SerializerSubclass', 'Spec::Serializer'
  end

  shared_context 'with a serializer with a default attribute' do
    before(:example) { Spec::Serializer.attribute :id }
  end

  shared_context 'with a serializer with a block attribute with no args' do
    let(:title_block) { -> { 'block with no args' } }

    before(:example) { Spec::Serializer.attribute(:title, &title_block) }
  end

  shared_context 'with a serializer with a block attribute with one arg' do
    let(:title_block) { ->(object) { object.inspect } }

    before(:example) { Spec::Serializer.attribute(:title, &title_block) }
  end

  shared_context 'with a serializer with a block attribute with any args' do
    let(:title_block) { ->(*args) { args.first.inspect } }

    before(:example) { Spec::Serializer.attribute(:title, &title_block) }
  end

  shared_context 'with a serializer with a block attribute with a keyword' do
    let(:title_block) do
      ->(_, serializers:) { { serializers: serializers }.inspect }
    end

    before(:example) { Spec::Serializer.attribute(:title, &title_block) }
  end

  shared_context 'with a serializer with a block attribute with any keywords' do
    let(:title_block) { ->(_, **keywords) { keywords.inspect } }

    before(:example) { Spec::Serializer.attribute(:title, &title_block) }
  end

  shared_context 'with a serializer with a block attribute with many params' do
    let(:title_block) do
      lambda do |object, serializers:|
        { object: object, serializers: serializers }.inspect
      end
    end

    before(:example) { Spec::Serializer.attribute(:title, &title_block) }
  end

  shared_context 'with a serializer with a serializer attribute' do
    let(:author_serializer) { Spec::AuthorSerializer.new }

    example_class 'Spec::AuthorSerializer',
      Cuprum::Rails::Serializers::Json::Serializer \
      do |klass|
        klass.define_method(:call) { |object, **_| "by: #{object}" }
      end

    before(:example) do
      Spec::Serializer.attribute :author, author_serializer
    end
  end

  shared_context 'with a serializer with multiple attributes' do
    include_context 'with a serializer with a default attribute'
    include_context 'with a serializer with a block attribute with one arg'
    include_context 'with a serializer with a serializer attribute'

    let(:title_block) { ->(object) { object.upcase } }
  end

  shared_context 'with a serializer subclass with additional attribute' do
    include_context 'with a serializer with multiple attributes'

    before(:example) { Spec::SerializerSubclass.attribute(:category) }
  end

  subject(:serializer) { described_class.new }

  describe '::AbstractSerializerError' do
    it 'should define the error class' do
      expect(described_class)
        .to define_constant(:AbstractSerializerError)
        .with_value(an_instance_of Class)
    end

    it 'should inherit from StandardError' do
      expect(described_class::AbstractSerializerError).to be < StandardError
    end
  end

  describe '.attribute' do
    shared_examples 'should add the serializer to attributes' do
      it 'should add the serializer to attributes' do
        expect do
          described_class.attribute(*[attr_name, value].compact, &block)
        end
          .to change(described_class, :attributes)
          .to(satisfy { |attributes| attributes[attr_name.to_s] == expected })
      end
    end

    let(:attr_name)  { :series }
    let(:value)      { nil }
    let(:block)      { nil }
    let(:expected)   { nil }
    let(:error_message) do
      'AttributesSerializer is an abstract class - create a subclass to' \
        ' define attributes'
    end

    it 'should define the method' do
      expect(described_class)
        .to respond_to(:attribute)
        .with(1..2).arguments
        .and_a_block
    end

    it 'should raise an exception' do
      expect { described_class.attribute(attr_name) }
        .to raise_error(
          described_class::AbstractSerializerError,
          error_message
        )
    end

    wrap_context 'with a serializer class' do
      describe 'with nil' do
        let(:error_message) { "attribute name can't be blank" }

        it 'should raise an exception' do
          expect { described_class.attribute(nil) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with an object' do
        let(:error_message) { 'attribute name must be a string or symbol' }

        it 'should raise an exception' do
          expect { described_class.attribute(Object.new.freeze) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with an empty string' do
        let(:error_message) { "attribute name can't be blank" }

        it 'should raise an exception' do
          expect { described_class.attribute('') }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with an empty symbol' do
        let(:error_message) { "attribute name can't be blank" }

        it 'should raise an exception' do
          expect { described_class.attribute(:'') }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a string' do
        let(:attr_name) { 'series' }

        include_examples 'should add the serializer to attributes'
      end

      describe 'with a string and an object' do
        let(:attr_name)     { 'series' }
        let(:value)         { Object.new.freeze }
        let(:error_message) { 'serializer must respond to #call' }

        it 'should raise an exception' do
          expect { described_class.attribute(attr_name, value) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a string and a block' do
        let(:attr_name) { 'series' }
        let(:block)     { ->(object, **_) { object.to_s } }
        let(:expected)  { block }

        include_examples 'should add the serializer to attributes'
      end

      describe 'with a string and a proc' do
        let(:attr_name) { 'series' }
        let(:value)     { ->(object, **_) { object.to_s } }
        let(:expected)  { value }

        include_examples 'should add the serializer to attributes'
      end

      describe 'with a string and a serializer' do
        let(:attr_name) { 'series' }
        let(:value)     { Spec::StringSerializer.new }
        let(:expected)  { value }

        example_class 'Spec::StringSerializer',
          Cuprum::Rails::Serializers::Json::Serializer \
          do |klass|
            klass.define_method(:call) { |object, **_| object.to_s }
          end

        include_examples 'should add the serializer to attributes'
      end

      describe 'with a symbol' do
        let(:attr_name) { :series }

        include_examples 'should add the serializer to attributes'
      end

      describe 'with a symbol and an object' do
        let(:attr_name)     { :series }
        let(:value)         { Object.new.freeze }
        let(:error_message) { 'serializer must respond to #call' }

        it 'should raise an exception' do
          expect { described_class.attribute(attr_name, value) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a symbol and a block' do
        let(:attr_name) { :series }
        let(:block)     { ->(object, **_) { object.to_s } }
        let(:expected)  { block }

        include_examples 'should add the serializer to attributes'
      end

      describe 'with a symbol and a proc' do
        let(:attr_name) { :series }
        let(:value)     { ->(object, **_) { object.to_s } }
        let(:expected)  { value }

        include_examples 'should add the serializer to attributes'
      end

      describe 'with a symbol and a serializer' do
        let(:attr_name) { :series }
        let(:value)     { Spec::StringSerializer.new }
        let(:expected)  { value }

        example_class 'Spec::StringSerializer',
          Cuprum::Rails::Serializers::Json::Serializer \
          do |klass|
            klass.define_method(:call) { |object, **_| object.to_s }
          end

        include_examples 'should add the serializer to attributes'
      end
    end

    wrap_context 'with a serializer subclass' do
      shared_examples 'should not update the parent class attributes' do
        it 'should not update the parent class attributes' do
          expect do
            described_class.attribute(*[attr_name, value].compact, &block)
          end
            .not_to change(described_class.superclass, :attributes)
        end
      end

      describe 'with a string' do
        let(:attr_name) { 'series' }

        include_examples 'should add the serializer to attributes'

        include_examples 'should not update the parent class attributes'
      end

      describe 'with a symbol' do
        let(:attr_name) { :series }

        include_examples 'should add the serializer to attributes'

        include_examples 'should not update the parent class attributes'
      end

      wrap_context 'with a serializer with multiple attributes' do
        describe 'with a string' do
          let(:attr_name) { 'series' }

          include_examples 'should add the serializer to attributes'

          include_examples 'should not update the parent class attributes'
        end

        describe 'with a string that is the name of an existing attribute' do
          let(:attr_name) { 'author' }

          include_examples 'should add the serializer to attributes'

          include_examples 'should not update the parent class attributes'
        end

        describe 'with a symbol' do
          let(:attr_name) { :series }

          include_examples 'should add the serializer to attributes'

          include_examples 'should not update the parent class attributes'
        end

        describe 'with a symbol that is the name of an existing attribute' do
          let(:attr_name) { :author }

          include_examples 'should add the serializer to attributes'

          include_examples 'should not update the parent class attributes'
        end
      end
    end
  end

  describe '.attributes' do
    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:attributes)
        .with(0).arguments
        .and_unlimited_arguments
        .and_any_keywords
    end

    it { expect(described_class.attributes).to be == {} }

    wrap_context 'with a serializer class' do
      it { expect(described_class.attributes).to be == {} }

      wrap_context 'with a serializer with a default attribute' do
        let(:expected) { { 'id' => nil } }

        it { expect(described_class.attributes).to be == expected }
      end

      # rubocop:disable RSpec/RepeatedExampleGroupBody
      wrap_context 'with a serializer with a block attribute with no args' do
        let(:expected) { { 'title' => title_block } }

        it { expect(described_class.attributes).to be == expected }
      end

      wrap_context 'with a serializer with a block attribute with one arg' do
        let(:expected) { { 'title' => title_block } }

        it { expect(described_class.attributes).to be == expected }
      end

      wrap_context 'with a serializer with a block attribute with any args' do
        let(:expected) { { 'title' => title_block } }

        it { expect(described_class.attributes).to be == expected }
      end

      wrap_context 'with a serializer with a block attribute with a keyword' do
        let(:expected) { { 'title' => title_block } }

        it { expect(described_class.attributes).to be == expected }
      end

      wrap_context 'with a serializer with a block attribute with any' \
                   ' keywords' \
      do
        let(:expected) { { 'title' => title_block } }

        it { expect(described_class.attributes).to be == expected }
      end

      wrap_context 'with a serializer with a block attribute with many' \
                   ' params' \
      do
        let(:expected) { { 'title' => title_block } }

        it { expect(described_class.attributes).to be == expected }
      end
      # rubocop:enable RSpec/RepeatedExampleGroupBody

      wrap_context 'with a serializer with a serializer attribute' do
        let(:expected) { { 'author' => author_serializer } }

        it { expect(described_class.attributes).to be == expected }
      end

      wrap_context 'with a serializer with multiple attributes' do
        let(:expected) do
          {
            'id'     => nil,
            'title'  => title_block,
            'author' => author_serializer
          }
        end

        it { expect(described_class.attributes).to be == expected }
      end
    end

    wrap_context 'with a serializer subclass' do
      it { expect(described_class.attributes).to be == {} }

      wrap_context 'with a serializer with a default attribute' do
        let(:expected) { { 'id' => nil } }

        it { expect(described_class.attributes).to be == expected }
      end

      # rubocop:disable RSpec/RepeatedExampleGroupBody
      wrap_context 'with a serializer with a block attribute with no args' do
        let(:expected) { { 'title' => title_block } }

        it { expect(described_class.attributes).to be == expected }
      end

      wrap_context 'with a serializer with a block attribute with one arg' do
        let(:expected) { { 'title' => title_block } }

        it { expect(described_class.attributes).to be == expected }
      end

      wrap_context 'with a serializer with a block attribute with any args' do
        let(:expected) { { 'title' => title_block } }

        it { expect(described_class.attributes).to be == expected }
      end

      wrap_context 'with a serializer with a block attribute with a keyword' do
        let(:expected) { { 'title' => title_block } }

        it { expect(described_class.attributes).to be == expected }
      end

      wrap_context 'with a serializer with a block attribute with any' \
                   ' keywords' \
      do
        let(:expected) { { 'title' => title_block } }

        it { expect(described_class.attributes).to be == expected }
      end

      wrap_context 'with a serializer with a block attribute with many' \
                   ' params' \
      do
        let(:expected) { { 'title' => title_block } }

        it { expect(described_class.attributes).to be == expected }
      end
      # rubocop:enable RSpec/RepeatedExampleGroupBody

      wrap_context 'with a serializer with a serializer attribute' do
        let(:expected) { { 'author' => author_serializer } }

        it { expect(described_class.attributes).to be == expected }
      end

      wrap_context 'with a serializer with multiple attributes' do
        let(:expected) do
          {
            'id'     => nil,
            'title'  => title_block,
            'author' => author_serializer
          }
        end

        it { expect(described_class.attributes).to be == expected }
      end

      wrap_context 'with a serializer subclass with additional attribute' do
        let(:expected) do
          {
            'id'       => nil,
            'title'    => title_block,
            'author'   => author_serializer,
            'category' => nil
          }
        end

        it { expect(described_class.attributes).to be == expected }
      end
    end
  end

  describe '#call' do
    shared_examples 'should serialize the attributes' do
      it 'should serialize the attributes' do
        expect(serializer.call(object, serializers: serializers))
          .to be == expected
      end
    end

    let(:object) do
      Book.new(
        id:           0,
        title:        'Gideon the Ninth',
        author:       'Tamsyn Muir',
        series:       'The Locked Tomb',
        category:     'Science Fiction & Fantasy',
        published_at: '2019-09-10'
      )
    end
    let(:serializers) do
      Cuprum::Rails::Serializers::Json.default_serializers
    end
    let(:expected) { {} }

    it 'should define the method' do
      expect(serializer)
        .to respond_to(:call)
        .with(1).argument
        .and_keywords(:serializers)
    end

    include_examples 'should serialize the attributes'

    wrap_context 'with a serializer class' do
      include_examples 'should serialize the attributes'

      wrap_context 'with a serializer with a default attribute' do
        let(:expected) { { 'id' => object.id } }

        include_examples 'should serialize the attributes'

        context 'when the object does not define the attribute' do
          let(:object) { Object.new.freeze }
          let(:error_message) do
            "undefined method `id' for #{object.inspect}"
          end

          it 'should raise an exception' do
            expect { serializer.call(object, serializers: serializers) }
              .to raise_error NoMethodError, error_message
          end
        end

        context 'when there is no serializer for the attribute' do
          let(:serializers)   { {} }
          let(:error_message) { 'no serializer defined for Integer' }

          it 'should raise an exception' do
            expect { serializer.call(object, serializers: serializers) }
              .to raise_error(
                described_class::UndefinedSerializerError,
                error_message
              )
          end
        end
      end

      wrap_context 'with a serializer with a block attribute with no args' do
        let(:expected) { { 'title' => 'block with no args' } }

        include_examples 'should serialize the attributes'
      end

      # rubocop:disable RSpec/RepeatedExampleGroupBody
      wrap_context 'with a serializer with a block attribute with one arg' do
        let(:expected) { { 'title' => object.title.inspect } }

        include_examples 'should serialize the attributes'
      end

      wrap_context 'with a serializer with a block attribute with any args' do
        let(:expected) { { 'title' => object.title.inspect } }

        include_examples 'should serialize the attributes'
      end

      wrap_context 'with a serializer with a block attribute with a keyword' do
        let(:expected) { { 'title' => { serializers: serializers }.inspect } }

        include_examples 'should serialize the attributes'
      end

      wrap_context 'with a serializer with a block attribute with any' \
                   ' keywords' \
      do
        let(:expected) { { 'title' => { serializers: serializers }.inspect } }

        include_examples 'should serialize the attributes'
      end
      # rubocop:enable RSpec/RepeatedExampleGroupBody

      wrap_context 'with a serializer with a block attribute with many' \
                   ' params' \
      do
        let(:expected) do
          {
            'title' => {
              object:      object.title,
              serializers: serializers
            }.inspect
          }
        end

        include_examples 'should serialize the attributes'
      end

      wrap_context 'with a serializer with a serializer attribute' do
        let(:expected) { { 'author' => "by: #{object.author}" } }

        include_examples 'should serialize the attributes'
      end

      wrap_context 'with a serializer with multiple attributes' do
        let(:expected) do
          {
            'id'     => object.id,
            'title'  => object.title.upcase,
            'author' => "by: #{object.author}"
          }
        end

        include_examples 'should serialize the attributes'
      end
    end

    wrap_context 'with a serializer subclass' do
      include_examples 'should serialize the attributes'

      wrap_context 'with a serializer with a default attribute' do
        let(:expected) { { 'id' => object.id } }

        include_examples 'should serialize the attributes'

        context 'when the object does not define the attribute' do
          let(:object) { Object.new.freeze }
          let(:error_message) do
            "undefined method `id' for #{object.inspect}"
          end

          it 'should raise an exception' do
            expect { serializer.call(object, serializers: serializers) }
              .to raise_error NoMethodError, error_message
          end
        end

        context 'when there is no serializer for the attribute' do
          let(:serializers)   { {} }
          let(:error_message) { 'no serializer defined for Integer' }

          it 'should raise an exception' do
            expect { serializer.call(object, serializers: serializers) }
              .to raise_error(
                described_class::UndefinedSerializerError,
                error_message
              )
          end
        end
      end

      wrap_context 'with a serializer with a block attribute with no args' do
        let(:expected) { { 'title' => 'block with no args' } }

        include_examples 'should serialize the attributes'
      end

      # rubocop:disable RSpec/RepeatedExampleGroupBody
      wrap_context 'with a serializer with a block attribute with one arg' do
        let(:expected) { { 'title' => object.title.inspect } }

        include_examples 'should serialize the attributes'
      end

      wrap_context 'with a serializer with a block attribute with any args' do
        let(:expected) { { 'title' => object.title.inspect } }

        include_examples 'should serialize the attributes'
      end

      wrap_context 'with a serializer with a block attribute with a keyword' do
        let(:expected) { { 'title' => { serializers: serializers }.inspect } }

        include_examples 'should serialize the attributes'
      end

      wrap_context 'with a serializer with a block attribute with any' \
                   ' keywords' \
      do
        let(:expected) { { 'title' => { serializers: serializers }.inspect } }

        include_examples 'should serialize the attributes'
      end

      wrap_context 'with a serializer with a block attribute with many' \
                   ' params' \
      do
        let(:expected) do
          {
            'title' => {
              object:      object.title,
              serializers: serializers
            }.inspect
          }
        end

        include_examples 'should serialize the attributes'
      end
      # rubocop:enable RSpec/RepeatedExampleGroupBody

      wrap_context 'with a serializer with a serializer attribute' do
        let(:expected) { { 'author' => "by: #{object.author}" } }

        include_examples 'should serialize the attributes'
      end

      wrap_context 'with a serializer with multiple attributes' do
        let(:expected) do
          {
            'id'     => object.id,
            'title'  => object.title.upcase,
            'author' => "by: #{object.author}"
          }
        end

        include_examples 'should serialize the attributes'
      end

      wrap_context 'with a serializer subclass with additional attribute' do
        let(:expected) do
          {
            'id'       => object.id,
            'title'    => object.title.upcase,
            'author'   => "by: #{object.author}",
            'category' => object.category
          }
        end

        include_examples 'should serialize the attributes'
      end
    end
  end
end
