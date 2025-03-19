# frozen_string_literal: true

require 'cuprum/rails/responders/base_responder'
require 'cuprum/rails/responders/html/rendering'

RSpec.describe Cuprum::Rails::Responders::Html::Rendering do
  subject(:responder) do
    described_class.new(action_name:, controller:, request:)
  end

  let(:described_class) { Spec::Responder }
  let(:action_name)     { :published }
  let(:controller)      { Spec::CustomController.new }
  let(:request)         { Cuprum::Rails::Request.new(**request_options) }
  let(:request_options) { {} }

  example_class 'Spec::CustomController' do |klass|
    klass.include(Cuprum::Rails::Controller)

    klass.define_singleton_method(:resource) do
      Cuprum::Rails::Resource.new(name: 'books')
    end
  end

  example_class 'Spec::Responder', Cuprum::Rails::Responders::BaseResponder \
  do |klass|
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

  describe '#redirect_back' do
    let(:options)  { {} }
    let(:response) { responder.redirect_back(**options) }
    let(:response_class) do
      Cuprum::Rails::Responses::Html::RedirectBackResponse
    end

    it 'should define the method' do
      expect(responder)
        .to respond_to(:redirect_back)
        .with(0).arguments
        .and_keywords(:fallback_location, :flash, :status)
    end

    it { expect(response).to be_a response_class }

    it { expect(response.fallback_location).to be == '/' }

    it { expect(response.flash).to be == {} }

    it { expect(response.status).to be 302 }

    describe 'with fallback_location: value' do
      let(:options) { super().merge(fallback_location: '/path/to/resource') }

      it { expect(response).to be_a response_class }

      it { expect(response.fallback_location).to be == '/path/to/resource' }

      it { expect(response.flash).to be == {} }

      it { expect(response.status).to be 302 }
    end

    describe 'with flash: value' do
      let(:flash) do
        {
          alert:  'Reactor temperature critical',
          notice: 'Initializing activation sequence'
        }
      end
      let(:options) { super().merge(flash:) }

      it { expect(response).to be_a response_class }

      it { expect(response.fallback_location).to be == '/' }

      it { expect(response.flash).to be == flash }

      it { expect(response.status).to be 302 }
    end

    describe 'with status: value' do
      let(:options) { super().merge(status: 303) }

      it { expect(response).to be_a response_class }

      it { expect(response.fallback_location).to be == '/' }

      it { expect(response.flash).to be == {} }

      it { expect(response.status).to be 303 }
    end
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
        .and_keywords(:flash, :status)
    end

    it { expect(response).to be_a response_class }

    it { expect(response.flash).to be == {} }

    it { expect(response.path).to be == path }

    it { expect(response.status).to be 302 }

    describe 'with flash: value' do
      let(:flash) do
        {
          alert:  'Reactor temperature critical',
          notice: 'Initializing activation sequence'
        }
      end
      let(:options) { super().merge(flash:) }

      it { expect(response).to be_a response_class }

      it { expect(response.flash).to be == flash }

      it { expect(response.path).to be == path }

      it { expect(response.status).to be 302 }
    end

    describe 'with status: value' do
      let(:status)  { 308 }
      let(:options) { super().merge(status:) }

      it { expect(response).to be_a response_class }

      it { expect(response.flash).to be == {} }

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
        .and_keywords(:assigns, :flash, :layout, :status)
    end

    it { expect(response).to be_a response_class }

    it { expect(response.assigns).to be == {} }

    it { expect(response.flash).to be == {} }

    it { expect(response.layout).to be nil }

    it { expect(response.status).to be 200 }

    it { expect(response.template).to be == template }

    context 'when the result is failing' do
      let(:result) { Cuprum::Result.new(status: :failure) }

      it { expect(response.assigns).to be == {} }

      context 'when the result has an error' do
        let(:error)    { Cuprum::Error.new(message: 'Something went wrong.') }
        let(:result)   { Cuprum::Result.new(status: :failure, error:) }
        let(:expected) { { error: } }

        it { expect(response.assigns).to be == expected }
      end

      context 'when the result has an error and a value' do
        let(:error)    { Cuprum::Error.new(message: 'Something went wrong.') }
        let(:value)    { { ok: false } }
        let(:expected) { value.merge(error:) }
        let(:result) do
          Cuprum::Result.new(status: :failure, error:, value:)
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
        let(:result)   { Cuprum::Result.new(status: :success, value:) }
        let(:expected) { value }

        it { expect(response.assigns).to be == expected }
      end
    end

    describe 'with assigns: value' do
      let(:assigns) { { key: 'value' } }
      let(:options) { super().merge(assigns:) }

      it { expect(response.assigns).to be == assigns }

      it { expect(response.flash).to be == {} }

      it { expect(response.layout).to be nil }

      it { expect(response.status).to be 200 }

      it { expect(response.template).to be == template }
    end

    describe 'with flash: value' do
      let(:flash) do
        {
          alert:  'Reactor temperature critical',
          notice: 'Initializing activation sequence'
        }
      end
      let(:options) { super().merge(flash:) }

      it { expect(response.assigns).to be == {} }

      it { expect(response.flash).to be == flash }

      it { expect(response.layout).to be nil }

      it { expect(response.status).to be 200 }

      it { expect(response.template).to be == template }
    end

    describe 'with layout: value' do
      let(:layout)  { 'page' }
      let(:options) { super().merge(layout:) }

      it { expect(response.assigns).to be == {} }

      it { expect(response.flash).to be == {} }

      it { expect(response.layout).to be == layout }

      it { expect(response.status).to be 200 }

      it { expect(response.template).to be == template }
    end

    describe 'with status: value' do
      let(:status)  { 201 }
      let(:options) { super().merge(status:) }

      it { expect(response.assigns).to be == {} }

      it { expect(response.flash).to be == {} }

      it { expect(response.layout).to be nil }

      it { expect(response.status).to be status }

      it { expect(response.template).to be == template }
    end

    describe 'with a turbo frame request' do
      let(:request_options) do
        headers =
          super()
            .fetch(:headers, {})
            .merge('HTTP_TURBO_FRAME' => '#frame_id')

        super().merge(headers:)
      end

      it { expect(response).to be_a response_class }

      it { expect(response.assigns).to be == {} }

      it { expect(response.flash).to be == {} }

      it { expect(response.layout).to be == 'turbo_rails/frame' }

      it { expect(response.status).to be 200 }

      it { expect(response.template).to be == template }

      describe 'with layout: value' do
        let(:layout)  { 'page' }
        let(:options) { super().merge(layout:) }

        it { expect(response.assigns).to be == {} }

        it { expect(response.flash).to be == {} }

        it { expect(response.layout).to be == layout }

        it { expect(response.status).to be 200 }

        it { expect(response.template).to be == template }
      end
    end
  end
end
