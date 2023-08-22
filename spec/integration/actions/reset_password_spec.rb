# frozen_string_literal: true

require 'support/actions/reset_password'

# @note Integration spec for Cuprum::Rails::RSpec::Actions::ParameterValidation.
RSpec.describe Spec::Support::Actions::ResetPassword do
  subject(:action) { described_class.new }

  describe '#call' do
    let(:authorization) { nil }
    let(:params)        { {} }
    let(:request) do
      Cuprum::Rails::Request.new(authorization: authorization, params: params)
    end

    describe 'with empty params' do
      let(:expected_error) do
        Cuprum::Error.new(message: 'not authorized')
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with an authorized request with empty params' do
      let(:authorization) { 'Bearer 12345' }
      let(:expected_errors) do
        Stannum::Errors.new.tap do |err|
          err[:password].add(Stannum::Constraints::Presence::TYPE)
          err[:confirmation].add(Stannum::Constraints::Presence::TYPE)
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

    describe 'with an authorized request with invalid params' do
      let(:authorization) { 'Bearer 12345' }
      let(:params) do
        super().merge('password' => 'tronlives', 'confirmation' => '')
      end
      let(:expected_errors) do
        Stannum::Errors.new.tap do |err|
          err[:confirmation].add(Stannum::Constraints::Presence::TYPE)
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

    describe 'with an authorized request with valid params' do
      let(:authorization) { 'Bearer 12345' }
      let(:params) do
        super().merge(
          'password'     => 'tronlives',
          'confirmation' => 'tronlives'
        )
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
