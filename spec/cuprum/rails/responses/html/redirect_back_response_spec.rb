# frozen_string_literal: true

require 'cuprum/rails/responses/html/redirect_back_response'

RSpec.describe Cuprum::Rails::Responses::Html::RedirectBackResponse do
  subject(:response) { described_class.new(**options) }

  let(:options) { {} }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:fallback_location, :status)
    end
  end

  describe '#call' do
    let(:renderer) do
      instance_double(ActionController::Base, redirect_back_or_to: nil)
    end

    it { expect(response).to respond_to(:call).with(1).argument }

    it 'should call redirect_back_or_to' do
      response.call(renderer)

      expect(renderer)
        .to have_received(:redirect_back_or_to)
        .with('/', status: 302)
    end

    context 'when initialized with fallback_location: value' do
      let(:options) { super().merge(fallback_location: '/path/to/resource') }

      it 'should call redirect_back_or_to' do
        response.call(renderer)

        expect(renderer)
          .to have_received(:redirect_back_or_to)
          .with('/path/to/resource', status: 302)
      end
    end

    context 'when initialized with status: value' do
      let(:options) { super().merge(status: 303) }

      it 'should call redirect_back_or_to' do
        response.call(renderer)

        expect(renderer)
          .to have_received(:redirect_back_or_to)
          .with('/', status: 303)
      end
    end
  end

  describe '#fallback_location' do
    include_examples 'should define reader', :fallback_location, '/'

    context 'when initialized with fallback_location: value' do
      let(:options) { super().merge(fallback_location: '/path/to/resource') }

      it { expect(response.fallback_location).to be == '/path/to/resource' }
    end
  end

  describe '#status' do
    include_examples 'should define reader', :status, 302

    context 'when initialized with status: value' do
      let(:options) { super().merge(status: 303) }

      it { expect(response.status).to be 303 }
    end
  end
end
