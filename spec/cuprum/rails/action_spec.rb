# frozen_string_literal: true

require 'cuprum/rails/action'
require 'cuprum/rails/repository'
require 'cuprum/rails/rspec/contracts/action_contracts'

RSpec.describe Cuprum::Rails::Action do
  include Cuprum::Rails::RSpec::Contracts::ActionContracts

  subject(:action) { described_class.new }

  let(:params)  { {} }
  let(:request) { instance_double(ActionDispatch::Request, params: params) }

  include_contract 'should be an action'

  describe '#call' do
    it 'should define the method' do
      expect(action)
        .to be_callable
        .with(0).arguments
        .and_keywords(:repository, :request)
        .and_any_keywords
    end

    it 'should return a passing result' do
      expect(action.call(request: request))
        .to be_a_passing_result(Cuprum::Rails::Result)
        .with_value(nil)
    end
  end

  describe '#options' do
    context 'when called with options' do
      let(:options) { { key: 'value' } }

      before(:example) { action.call(request: request, **options) }

      it { expect(action.options).to be == options }
    end
  end

  describe '#params' do
    context 'when called with a request' do
      before(:example) { action.call(request: request) }

      it { expect(action.params).to be == params }
    end

    context 'when called with a request with parameters' do
      let(:params) do
        {
          'book' => {
            'title' => 'Tamsyn Muir'
          },
          'key'  => 'value'
        }
      end

      before(:example) { action.call(request: request) }

      it { expect(action.params).to be == params }
    end
  end

  describe '#repository' do
    include_examples 'should define reader', :repository

    context 'when called with a repository' do
      let(:repository) { Cuprum::Rails::Repository.new }

      before(:example) { action.call(repository: repository, request: request) }

      it { expect(action.repository).to be repository }
    end
  end

  describe '#request' do
    context 'when called with a request' do
      before(:example) { action.call(request: request) }

      it { expect(action.request).to be == request }
    end
  end
end
