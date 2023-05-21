# frozen_string_literal: true

require 'cuprum/rails/responders/html/rendering'

RSpec.describe Cuprum::Rails::Responders::Html::Rendering do
  subject(:responder) { described_class.new }

  let(:described_class) { Spec::Responder }

  example_class 'Spec::Responder' do |klass|
    klass.include Cuprum::Rails::Responders::Html::Rendering # rubocop:disable RSpec/DescribedClass

    klass.attr_reader :result
  end

  describe '#head' do
    let(:status)   { 500 }
    let(:options)  { { status: 500 } }
    let(:response) { responder.head(**options) }
    let(:response_class) do
      Cuprum::Rails::Responses::HeadResponse
    end

    it 'should define the method' do
      expect(responder)
        .to respond_to(:head)
        .with(0).arguments
        .and_keywords(:status)
    end

    it { expect(response).to be_a response_class }

    it { expect(response.status).to be 500 }
  end

  describe '#redirect_to' do
    let(:path)     { 'www.example.com' }
    let(:options)  { {} }
    let(:response) { responder.redirect_to(path, **options) }
    let(:response_class) do
      Cuprum::Rails::Responses::Html::RedirectResponse
    end

    it 'should define the method' do
      expect(responder)
        .to respond_to(:redirect_to)
        .with(1).argument
        .and_keywords(:status)
    end

    it { expect(response).to be_a response_class }

    it { expect(response.path).to be == path }

    it { expect(response.status).to be 302 }

    describe 'with status: value' do
      let(:status)  { 308 }
      let(:options) { super().merge(status: status) }

      it { expect(response).to be_a response_class }

      it { expect(response.path).to be == path }

      it { expect(response.status).to be status }
    end
  end

  describe '#render' do
    let(:template) { :process }
    let(:options)  { {} }
    let(:result)   { Cuprum::Result.new }
    let(:response) { responder.render(template, **options) }
    let(:response_class) do
      Cuprum::Rails::Responses::Html::RenderResponse
    end

    before(:example) do
      allow(responder) # rubocop:disable RSpec/SubjectStub
        .to receive(:result)
        .and_return(result)
    end

    it 'should define the method' do
      expect(responder)
        .to respond_to(:render)
        .with(1).argument
        .and_keywords(:assigns, :layout, :status)
    end

    it { expect(response).to be_a response_class }

    it { expect(response.layout).to be nil }

    it { expect(response.status).to be 200 }

    it { expect(response.template).to be == template }

    context 'when the result is failing' do
      let(:result) { Cuprum::Result.new(status: :failure) }

      it { expect(response.assigns).to be == {} }

      context 'when the result has an error' do
        let(:error)    { Cuprum::Error.new(message: 'Something went wrong.') }
        let(:result)   { Cuprum::Result.new(status: :failure, error: error) }
        let(:expected) { { error: error } }

        it { expect(response.assigns).to be == expected }
      end

      context 'when the result has an error and a value' do
        let(:error)    { Cuprum::Error.new(message: 'Something went wrong.') }
        let(:value)    { { ok: false } }
        let(:expected) { value.merge(error: error) }
        let(:result) do
          Cuprum::Result.new(status: :failure, error: error, value: value)
        end

        it { expect(response.assigns).to be == expected }
      end
    end

    context 'when the result is passing' do
      let(:result) { Cuprum::Result.new(status: :success) }

      it { expect(response.assigns).to be == {} }

      context 'when the result has a non-Hash value' do
        let(:result)   { Cuprum::Result.new(status: :success, value: :ok) }
        let(:expected) { { value: :ok } }

        it { expect(response.assigns).to be == expected }
      end

      context 'when the result has a Hash value' do
        let(:value)    { { ok: true } }
        let(:result)   { Cuprum::Result.new(status: :success, value: value) }
        let(:expected) { value }

        it { expect(response.assigns).to be == expected }
      end
    end

    describe 'with assigns: value' do
      let(:assigns) { { key: 'value' } }
      let(:options) { super().merge(assigns: assigns) }

      it { expect(response.assigns).to be == assigns }
    end

    describe 'with layout: value' do
      let(:layout)  { 'page' }
      let(:options) { super().merge(layout: layout) }

      it { expect(response.layout).to be == layout }
    end

    describe 'with status: value' do
      let(:status)  { 201 }
      let(:options) { super().merge(status: status) }

      it { expect(response.status).to be status }
    end
  end
end
