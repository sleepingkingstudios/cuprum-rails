# frozen_string_literal: true

require 'cuprum/rails/actions/middleware/log_result'

RSpec.describe Cuprum::Rails::Actions::Middleware::LogResult do
  subject(:middleware) { described_class.new }

  describe '.new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#call' do
    let(:next_result)  { Cuprum::Result.new(value: { 'ok' => true }) }
    let(:next_command) { instance_double(Cuprum::Command, call: next_result) }
    let(:request)      { Cuprum::Rails::Request.new }
    let(:options)      { {} }
    let(:logger) do
      instance_double(ActiveSupport::Logger, error: nil, info: nil)
    end
    let(:expected) do
      <<~TEXT.then { |str| format_expected(str) }
        Cuprum::Rails::Actions::Middleware::LogResult#process
          Status
            :success

          Value
            {"ok"=>true}

          Error
            nil
      TEXT
    end

    before(:example) do
      allow(Rails).to receive(:logger).and_return(logger)
    end

    def call_middleware
      middleware.call(next_command, request:, **options)
    end

    def format_expected(str)
      expected =
        str
          .lines
          .map { |line| line == "\n" ? "\n" : "  #{line}" }
          .join

      return expected unless RUBY_VERSION >= '3.4.0'

      expected
        .gsub(/:\w+=>/) { |match| "#{match[1...-2]}: " }
        .gsub('=>', ' => ')
    end

    it 'should define the method' do
      expect(middleware)
        .to be_callable
        .with(1).argument
        .and_keywords(:request)
        .and_any_keywords
    end

    it 'should call the next command' do
      call_middleware

      expect(next_command)
        .to have_received(:call)
        .with(request:, **options)
    end

    it 'should return the next result' do
      expect(call_middleware)
        .to be_a_passing_result
        .with_value({ 'ok' => true })
    end

    it 'should log the result' do
      call_middleware

      expect(logger).to have_received(:info).with(expected)
    end

    describe 'with custom options' do
      let(:options) { { key: 'custom value' } }

      it 'should call the next command' do
        call_middleware

        expect(next_command)
          .to have_received(:call)
          .with(request:, **options)
      end
    end

    context 'when the next result is failing' do
      let(:next_error) { Cuprum::Error.new(message: 'Something went wrong') }
      let(:next_result) do
        Cuprum::Result.new(
          error: next_error,
          value: { 'ok' => false }
        )
      end
      let(:expected) do
        <<~TEXT.then { |str| format_expected(str) }
          Cuprum::Rails::Actions::Middleware::LogResult#process
            Status
              :failure

            Value
              {"ok"=>false}

            Error
              #<Cuprum::Error:0x#{next_error.inspect[18...34]}
               @comparable_properties={:message=>"Something went wrong", :type=>nil},
               @message="Something went wrong",
               @type="cuprum.error">
        TEXT
      end

      it 'should log the result' do
        call_middleware

        expect(logger).to have_received(:error).with(expected)
      end
    end

    context 'when the next result has metadata' do
      let(:next_result) do
        Cuprum::Rails::Result.new(
          value:    { 'ok' => true },
          metadata: { 'env' => :test }
        )
      end
      let(:expected) do
        <<~TEXT.then { |str| format_expected(str) }
          Cuprum::Rails::Actions::Middleware::LogResult#process
            Status
              :success

            Value
              {"ok"=>true}

            Error
              nil

            Metadata
              {"env"=>:test}
        TEXT
      end

      it 'should return the next result' do
        expect(call_middleware)
          .to be_a_passing_result
          .with_value({ 'ok' => true })
          .and_metadata({ 'env' => :test })
      end

      it 'should log the result' do
        call_middleware

        expect(logger).to have_received(:info).with(expected)
      end
    end
  end
end
