# frozen_string_literal: true

require 'cuprum/rails/transaction'

require 'support/book'

RSpec.describe Cuprum::Rails::Transaction do
  subject(:command) { described_class.new }

  describe '.new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#call' do
    describe 'with a block that returns nil' do
      let(:block) do
        lambda do
          Book.create!(title: 'Gideon the Ninth', author: 'Tammsyn Muir')

          nil
        end
      end

      it 'should return a passing result' do
        expect(command.call(&block))
          .to be_a_passing_result
          .with_value(nil)
      end

      it 'should not roll back the transaction' do
        expect { command.call(&block) }
          .to change(Book, :count)
          .by(1)
      end
    end

    describe 'with a block that returns a value' do
      let(:value) { { 'ok' => true } }
      let(:block) do
        lambda do
          Book.create!(title: 'Gideon the Ninth', author: 'Tammsyn Muir')

          value
        end
      end

      it 'should return a passing result' do
        expect(command.call(&block))
          .to be_a_passing_result
          .with_value(value)
      end

      it 'should not roll back the transaction' do
        expect { command.call(&block) }
          .to change(Book, :count)
          .by(1)
      end
    end

    describe 'with a block that returns a failing result' do
      let(:value)  { { 'ok' => false } }
      let(:error)  { Cuprum::Error.new(message: 'Something went wrong') }
      let(:result) { Cuprum::Result.new(value:, error:) }
      let(:block) do
        lambda do
          Book.create!(title: 'Gideon the Ninth', author: 'Tammsyn Muir')

          result
        end
      end

      it { expect(command.call(&block)).to be == result }

      it 'should roll back the transaction' do
        expect { command.call(&block) }.not_to change(Book, :count)
      end
    end

    describe 'with a block that returns a passing result' do
      let(:value)  { { 'ok' => true } }
      let(:result) { Cuprum::Result.new(value:) }
      let(:block) do
        lambda do
          Book.create!(title: 'Gideon the Ninth', author: 'Tammsyn Muir')

          result
        end
      end

      it { expect(command.call(&block)).to be == result }

      it 'should not roll back the transaction' do
        expect { command.call(&block) }
          .to change(Book, :count)
          .by(1)
      end
    end

    describe 'with a block that raises an exception' do
      let(:error_message) { 'Something went wrong' }
      let(:block) do
        lambda do
          Book.create!(title: 'Gideon the Ninth', author: 'Tammsyn Muir')

          raise error_message
        end
      end
      let(:expected_error) do
        Cuprum::Errors::UncaughtException.new(
          exception: RuntimeError.new(error_message),
          message:   'uncaught exception in transaction -'
        )
      end

      it 'should return a failing result' do
        expect(command.call(&block))
          .to be_a_failing_result
          .with_error(expected_error)
      end

      it 'should roll back the transaction' do
        expect { command.call(&block) }.not_to change(Book, :count)
      end
    end
  end
end
