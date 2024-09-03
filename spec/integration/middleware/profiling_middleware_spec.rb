# frozen_string_literal: true

require 'support/middleware/profiling_middleware'

# @note Integration spec for Controller middleware.
RSpec.describe Spec::Support::Middleware::ProfilingMiddleware do
  subject(:middleware) { described_class.new }

  let(:command) { instance_double(Cuprum::Command, call: result) }
  let(:result)  { Cuprum::Result.new }
  let(:request) { Object.new.freeze }

  describe '#call' do
    it 'should call the command' do
      middleware.call(command, request:)

      expect(command).to have_received(:call).with(request:)
    end

    it 'should return the result' do
      expect(middleware.call(command, request:)).to be == result
    end

    context 'when the result has a value' do
      let(:current_time) { Time.current }
      let(:value)        { { 'ok' => true } }
      let(:result)       { Cuprum::Result.new(value:) }
      let(:expected)     { value.merge('time_elapsed' => '50 milliseconds') }

      before(:example) do
        allow(Time)
          .to receive(:current)
          .and_return(current_time, current_time + 0.05)
      end

      it 'should return a passing result' do
        expect(middleware.call(command, request:))
          .to be_a_passing_result
          .with_value(expected)
      end
    end
  end
end
