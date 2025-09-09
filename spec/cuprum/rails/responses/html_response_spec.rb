# frozen_string_literal: true

require 'cuprum/rails/responses/html_response'

RSpec.describe Cuprum::Rails::Responses::HtmlResponse do
  subject(:response) { described_class.new(**constructor_options) }

  let(:html)                { '<h1>Greetings, Programs!</h1>' }
  let(:constructor_options) { { html: } }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:html, :layout, :status)
    end
  end

  describe '#call' do
    let(:renderer) { instance_double(Spec::Renderer, render: nil) }
    let(:expected_keywords) do
      {
        html:   response.html,
        layout: response.layout,
        status: response.status
      }
    end

    example_class 'Spec::Renderer' do |klass|
      klass.define_method(:render) { |**| nil }
    end

    it { expect(response).to respond_to(:call).with(1).argument }

    it 'should delegate to the #render method' do
      response.call(renderer)

      expect(renderer)
        .to have_received(:render)
        .with(**expected_keywords)
    end

    context 'when initialized with layout: value' do
      let(:layout)              { :hero }
      let(:constructor_options) { super().merge(layout:) }

      it 'should delegate to the #render method' do
        response.call(renderer)

        expect(renderer)
          .to have_received(:render)
          .with(**expected_keywords)
      end
    end

    context 'when initialized with status: value' do
      let(:status)              { 422 }
      let(:constructor_options) { super().merge(status:) }

      it 'should delegate to the #render method' do
        response.call(renderer)

        expect(renderer)
          .to have_received(:render)
          .with(**expected_keywords)
      end
    end
  end

  describe '#html' do
    include_examples 'should define reader', :html, -> { html }
  end

  describe '#layout' do
    include_examples 'should define reader', :layout, -> { true }

    context 'when initialized with layout: false' do
      let(:constructor_options) { super().merge(layout: false) }

      it { expect(response.layout).to be false }
    end

    context 'when initialized with layout: true' do
      let(:constructor_options) { super().merge(layout: true) }

      it { expect(response.layout).to be true }
    end

    context 'when initialized with layout: value' do
      let(:layout)              { :hero }
      let(:constructor_options) { super().merge(layout:) }

      it { expect(response.layout).to be == layout }
    end
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
