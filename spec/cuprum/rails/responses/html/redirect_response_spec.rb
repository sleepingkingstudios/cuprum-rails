# frozen_string_literal: true

require 'cuprum/rails/responses/html/redirect_response'

RSpec.describe Cuprum::Rails::Responses::Html::RedirectResponse do
  subject(:response) { described_class.new(path, **options) }

  let(:path)    { '/books' }
  let(:options) { {} }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(1).argument
        .and_keywords(:status)
    end
  end

  describe '#call' do
    let(:renderer) { instance_double(ActionController::Base, redirect_to: nil) }

    it { expect(response).to respond_to(:call).with(1).argument }

    it 'should call redirect_to' do
      response.call(renderer)

      expect(renderer)
        .to have_received(:redirect_to)
        .with(path, status: 302)
    end

    context 'when initialized with status: value' do
      let(:options) { super().merge(status: 303) }

      it 'should call redirect_to' do
        response.call(renderer)

        expect(renderer)
          .to have_received(:redirect_to)
          .with(path, status: 303)
      end
    end
  end

  describe '#path' do
    include_examples 'should define reader', :path, -> { be == path }
  end

  describe '#status' do
    include_examples 'should define reader', :status, 302

    context 'when initialized with status: value' do
      let(:options) { super().merge(status: 303) }

      it { expect(response.status).to be 303 }
    end
  end
end
