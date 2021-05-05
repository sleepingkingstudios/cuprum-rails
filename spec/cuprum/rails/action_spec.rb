# frozen_string_literal: true

require 'cuprum/rails/action'

RSpec.describe Cuprum::Rails::Action do
  subject(:action) { described_class.new(resource: resource) }

  let(:resource) { Cuprum::Rails::Resource.new(resource_name: 'books') }

  def be_callable
    respond_to(:process, true)
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:resource)
    end
  end

  describe '#call' do
    let(:request) { instance_double(ActionDispatch::Request) }

    it 'should define the method' do
      expect(action).to be_callable.with(0).arguments.and_keywords(:request)
    end

    it 'should return a passing result' do
      expect(action.call(request: request))
        .to be_a_passing_result.with_value(nil)
    end
  end

  describe '#params' do
    let(:expected) { {} }
    let(:request) do
      instance_double(ActionDispatch::Request, params: expected)
    end
    let(:action) { super().tap { |action| action.call(request: request) } }

    it 'should define the private method' do
      expect(action).to respond_to(:params, true).with(0).arguments
    end

    it { expect(action.send(:params)).to be_a ActionController::Parameters }

    it { expect(action.send(:params).to_unsafe_hash).to be == expected }

    context 'when the request has parameters' do
      let(:expected) do
        {
          'book' => {
            'title' => 'Tammsyn Muir'
          },
          'key'  => 'value'
        }
      end

      it { expect(action.send(:params).to_unsafe_hash).to be == expected }
    end
  end

  describe '#resource' do
    include_examples 'should define reader', :resource, -> { resource }
  end
end
