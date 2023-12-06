# frozen_string_literal: true

require 'support/actions/login'

# @note Integration spec for
#   Cuprum::Rails::RSpec::Contracts::Actions::ParameterValidation.
RSpec.describe Spec::Support::Actions::Login do
  subject(:action) { described_class.new }

  describe '#call' do
    let(:params)  { {} }
    let(:request) { Cuprum::Rails::Request.new(params: params) }

    describe 'with empty params' do
      let(:expected_errors) do
        Stannum::Errors.new.tap do |err|
          err[:username].add(Stannum::Constraints::Presence::TYPE)
          err[:password].add(Stannum::Constraints::Presence::TYPE)
        end
      end
      let(:expected_error) do
        Cuprum::Rails::Errors::InvalidParameters.new(errors: expected_errors)
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with invalid params' do
      let(:params) do
        super().merge('username' => 'Alan Bradley', 'password' => '')
      end
      let(:expected_errors) do
        Stannum::Errors.new.tap do |err|
          err[:password].add(Stannum::Constraints::Presence::TYPE)
        end
      end
      let(:expected_error) do
        Cuprum::Rails::Errors::InvalidParameters.new(errors: expected_errors)
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with valid params' do
      let(:params) do
        super().merge('username' => 'Alan Bradley', 'password' => 'tronlives')
      end
      let(:expected_value) { { 'ok' => true } }

      it 'should return a passing result' do
        expect(action.call(request: request))
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end
  end
end
