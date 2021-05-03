# frozen_string_literal: true

require 'cuprum/rails/map_errors'

require 'support/book'

RSpec.describe Cuprum::Rails::MapErrors do
  subject(:mapping) { described_class.instance }

  describe '.instance' do
    it { expect(described_class).to respond_to(:instance).with(0).arguments }

    it { expect(described_class.instance).to be_a described_class }

    it { expect(described_class.instance).to be described_class.instance }
  end

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(0).arguments }
  end

  describe '#call' do
    it 'should define the method' do
      expect(mapping)
        .to respond_to(:call)
        .with(0).arguments
        .and_keywords(:native_errors)
    end

    describe 'with nil' do
      let(:error_message) do
        'native_errors must be an instance of ActiveModel::Errors'
      end

      it 'should raise an error' do
        expect { mapping.call(native_errors: nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      let(:error_message) do
        'native_errors must be an instance of ActiveModel::Errors'
      end

      it 'should raise an error' do
        expect { mapping.call(native_errors: Object.new.freeze) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty errors object' do
      let(:book) do
        Book.new(
          {
            title:  'Gideon the Ninth',
            author: 'Tammsyn Muir'
          }
        )
      end
      let(:errors)          { book.tap(&:valid?).errors }
      let(:expected_errors) { Stannum::Errors.new }

      it { expect(mapping.call(native_errors: errors)).to be_a Stannum::Errors }

      it 'should map the errors' do
        expect(mapping.call(native_errors: errors)).to be == expected_errors
      end
    end

    describe 'with an errors object with errors' do
      let(:book)   { Book.new }
      let(:errors) { book.tap(&:valid?).errors }
      let(:expected_errors) do
        errors = Stannum::Errors.new

        errors[:title].add('blank', message: "can't be blank")
        errors[:author].add('blank', message: "can't be blank")

        errors
      end

      it { expect(mapping.call(native_errors: errors)).to be_a Stannum::Errors }

      it 'should map the errors' do
        expect(mapping.call(native_errors: errors)).to be == expected_errors
      end
    end

    describe 'with an errors object with errors on the base record' do
      let(:book)   { Spec::UnpublishedBook.new }
      let(:errors) { book.tap(&:valid?).errors }
      let(:expected_errors) do
        errors = Stannum::Errors.new

        errors.add('invalid', message: 'is invalid')
        errors[:title].add('blank', message: "can't be blank")
        errors[:author].add('blank', message: "can't be blank")

        errors
      end

      example_class 'Spec::UnpublishedBook', Book do |klass|
        klass.define_method :book_is_unpublished do
          errors.add(:base, :invalid)
        end

        klass.validate :book_is_unpublished
      end

      it { expect(mapping.call(native_errors: errors)).to be_a Stannum::Errors }

      it 'should map the errors' do
        expect(mapping.call(native_errors: errors)).to be == expected_errors
      end
    end

    describe 'with an errors object with error details' do
      let(:book)   { Spec::RareBook.new(id: 0) }
      let(:errors) { book.tap(&:valid?).errors }
      let(:expected_errors) do
        errors = Stannum::Errors.new

        errors[:title].add('blank', message: "can't be blank")
        errors[:author].add('blank', message: "can't be blank")
        errors[:id].add(
          'greater_than',
          count:   2,
          message: 'must be greater than 2',
          value:   0
        )

        errors
      end

      example_class 'Spec::RareBook', Book do |klass|
        klass.validates :id, numericality: { greater_than: 2 }
      end

      it { expect(mapping.call(native_errors: errors)).to be_a Stannum::Errors }

      it 'should map the errors' do
        expect(mapping.call(native_errors: errors)).to be == expected_errors
      end
    end

    describe 'with an errors object with a custom message' do
      let(:book)   { Spec::CensoredBook.new(title: 'Work and Play') }
      let(:errors) { book.tap(&:valid?).errors }
      let(:expected_errors) do
        errors = Stannum::Errors.new

        errors[:title].add('invalid', message: 'has four letter words')
        errors[:author].add('blank', message: "can't be blank")

        errors
      end

      example_class 'Spec::CensoredBook', Book do |klass|
        klass.validate :title_cannot_swear

        klass.define_method :title_cannot_swear do
          words = title.split

          return  unless words.any? { |word| word.length == 4 }

          errors.add(:title, :invalid, message: 'has four letter words')
        end
      end

      it { expect(mapping.call(native_errors: errors)).to be_a Stannum::Errors }

      it 'should map the errors' do
        expect(mapping.call(native_errors: errors)).to be == expected_errors
      end
    end
  end
end
