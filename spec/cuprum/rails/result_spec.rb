# frozen_string_literal: true

require 'cuprum/rails/result'

RSpec.describe Cuprum::Rails::Result do
  subject(:result) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:error, :metadata, :status, :value)
    end
  end

  describe '#==' do
    let(:other_options) { {} }
    let(:other_result)  { described_class.new(**other_options) }

    it { expect(result == other_result).to be true }

    describe 'with a base result with non-matching properties' do
      let(:other_options) { super().merge(value: { ok: true }) }
      let(:other_result)  { Cuprum::Result.new(**other_options) }

      it { expect(result == other_result).to be false }
    end

    describe 'with a base result with matching properties' do
      let(:other_result) { Cuprum::Result.new(**constructor_options) }

      it { expect(result == other_result).to be false }
    end

    describe 'with a result with non-matching metadata' do
      let(:other_metadata) { { session: nil } }
      let(:other_options)  { super().merge(metadata: other_metadata) }

      it { expect(result == other_result).to be false }
    end

    describe 'with a result with non-matching properties' do
      let(:other_options) { super().merge(value: { ok: true }) }

      it { expect(result == other_result).to be false }
    end

    context 'when initialized with metadata: a Hash' do
      let(:metadata) { { session: { token: '12345' } } }
      let(:constructor_options) do
        super().merge(metadata:)
      end

      it { expect(result == other_result).to be false }

      describe 'with a result with non-matching metadata' do
        let(:other_metadata) { { session: nil } }
        let(:other_options)  { super().merge(metadata: other_metadata) }

        it { expect(result == other_result).to be false }
      end

      describe 'with a result with matching metadata' do
        let(:other_options) { super().merge(metadata:) }

        it { expect(result == other_result).to be true }
      end
    end

    context 'when initialized with properties' do
      let(:error) { Cuprum::Error.new(message: 'Something went wrong') }
      let(:constructor_options) do
        super().merge(error:, value: { ok: false })
      end

      describe 'with a base result with non-matching properties' do
        let(:other_options) { super().merge(value: { ok: true }) }
        let(:other_result)  { Cuprum::Result.new(**other_options) }

        it { expect(result == other_result).to be false }
      end

      describe 'with a base result with matching properties' do
        let(:other_result) { Cuprum::Result.new(**constructor_options) }

        it { expect(result == other_result).to be false }
      end

      describe 'with a result with non-matching metadata' do
        let(:other_metadata) { { session: nil } }
        let(:other_options) do
          constructor_options.merge(metadata: other_metadata)
        end

        it { expect(result == other_result).to be false }
      end

      describe 'with a result with non-matching properties' do
        let(:other_options) { super().merge(value: { ok: true }) }

        it { expect(result == other_result).to be false }
      end

      describe 'with a result with matching properties and metadata' do
        let(:other_result) { described_class.new(**constructor_options) }

        it { expect(result == other_result).to be true }
      end
    end

    context 'when initialized with properties and metadata' do
      let(:metadata) { { session: { token: '12345' } } }
      let(:error)    { Cuprum::Error.new(message: 'Something went wrong') }
      let(:constructor_options) do
        super().merge(error:, metadata:, value: { ok: false })
      end

      describe 'with a base result with non-matching properties' do
        let(:other_options) { super().merge(value: { ok: true }) }
        let(:other_result)  { Cuprum::Result.new(**other_options) }

        it { expect(result == other_result).to be false }
      end

      describe 'with a base result with matching properties' do
        let(:other_options) { constructor_options.except(:metadata) }
        let(:other_result)  { Cuprum::Result.new(**other_options) }

        it { expect(result == other_result).to be false }
      end

      describe 'with a result with non-matching metadata' do
        let(:other_metadata) { { session: nil } }
        let(:other_options) do
          constructor_options.merge(metadata: other_metadata)
        end

        it { expect(result == other_result).to be false }
      end

      describe 'with a result with non-matching properties' do
        let(:other_options) { super().merge(value: { ok: true }) }

        it { expect(result == other_result).to be false }
      end

      describe 'with a result with matching properties and metadata' do
        let(:other_result) { described_class.new(**constructor_options) }

        it { expect(result == other_result).to be true }
      end
    end
  end

  describe '#error' do
    include_examples 'should define reader', :error, nil

    context 'when initialized with error: a value' do
      let(:error) { Cuprum::Error.new(message: 'Something went wrong') }
      let(:constructor_options) do
        super().merge(error:)
      end

      it { expect(result.error).to be == error }
    end
  end

  describe '#metadata' do
    include_examples 'should define reader', :metadata, {}

    context 'when initialized with metadata: a Hash' do
      let(:metadata) { { session: { token: '12345' } } }
      let(:constructor_options) do
        super().merge(metadata:)
      end

      it { expect(result.metadata).to be == metadata }
    end
  end

  describe '#properties' do
    let(:expected) do
      {
        error:    result.error,
        metadata: result.metadata,
        status:   result.status,
        value:    result.value
      }
    end

    include_examples 'should define reader', :properties, -> { be == expected }

    it { expect(result).to have_aliased_method(:properties).as(:to_h) }

    context 'when initialized with metadata: a Hash' do
      let(:metadata) { { session: { token: '12345' } } }
      let(:constructor_options) do
        super().merge(metadata:)
      end

      it { expect(result.properties).to be == expected }
    end

    context 'when initialized with properties' do
      let(:error) { Cuprum::Error.new(message: 'Something went wrong') }
      let(:constructor_options) do
        super().merge(error:, value: { ok: false })
      end

      it { expect(result.properties).to be == expected }
    end

    context 'when initialized with properties and metadata' do
      let(:metadata) { { session: { token: '12345' } } }
      let(:error)    { Cuprum::Error.new(message: 'Something went wrong') }
      let(:constructor_options) do
        super().merge(error:, metadata:, value: { ok: false })
      end

      it { expect(result.properties).to be == expected }
    end
  end

  describe '#status' do
    include_examples 'should define reader', :status, :success

    context 'when initialized with error: a value' do
      let(:error) { Cuprum::Error.new(message: 'Something went wrong') }
      let(:constructor_options) do
        super().merge(error:)
      end

      it { expect(result.status).to be :failure }

      context 'when initialized with status: failure' do
        let(:constructor_options) { super().merge(status: :failure) }

        it { expect(result.status).to be :failure }
      end

      context 'when initialized with status: success' do
        let(:constructor_options) { super().merge(status: :success) }

        it { expect(result.status).to be :success }
      end
    end

    context 'when initialized with status: failure' do
      let(:constructor_options) { super().merge(status: :failure) }

      it { expect(result.status).to be :failure }
    end

    context 'when initialized with status: success' do
      let(:constructor_options) { super().merge(status: :success) }

      it { expect(result.status).to be :success }
    end
  end

  describe '#value' do
    include_examples 'should define reader', :value, nil

    context 'when initialized with value: an object' do
      let(:value) { { ok: true } }
      let(:constructor_options) do
        super().merge(value:)
      end

      it { expect(result.value).to be value }
    end
  end
end
