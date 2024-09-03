# frozen_string_literal: true

require 'cuprum/rails/responses/json_response'

RSpec.describe Cuprum::Rails::Responses::JsonResponse do
  subject(:response) { described_class.new(**constructor_options) }

  let(:data)                { { 'key' => 'value' } }
  let(:constructor_options) { { data: } }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:data, :status)
    end
  end

  describe '#call' do
    let(:renderer) { instance_double(Spec::Renderer, render: nil) }

    example_class 'Spec::Renderer' do |klass|
      klass.define_method(:render) { |**_| nil }
    end

    it { expect(response).to respond_to(:call).with(1).argument }

    it 'should delegate to the #render method' do
      response.call(renderer)

      expect(renderer)
        .to have_received(:render)
        .with(json: response.data, status: response.status)
    end

    context 'when initialized with status: value' do
      let(:status)              { 422 }
      let(:constructor_options) { super().merge(status:) }

      it 'should delegate to the #render method' do
        response.call(renderer)

        expect(renderer)
          .to have_received(:render)
          .with(json: response.data, status: response.status)
      end
    end
  end

  describe '#data' do
    include_examples 'should define reader', :data, -> { be == data }
  end

  describe '#status' do
    include_examples 'should define reader', :status, 200

    context 'when initialized with status: value' do
      let(:status)              { 422 }
      let(:constructor_options) { super().merge(status:) }

      it { expect(response.status).to be status }
    end
  end
end
