# frozen_string_literal: true

require 'cuprum/rails/responses/html/render_response'

RSpec.describe Cuprum::Rails::Responses::Html::RenderResponse do
  subject(:response) { described_class.new(template, **options) }

  let(:template) { 'index' }
  let(:options)  { {} }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(1).argument
        .and_keywords(:assigns, :flash, :layout, :status)
    end
  end

  describe '#assigns' do
    include_examples 'should define reader', :assigns, -> { be == {} }

    context 'when initialized with assigns: a Hash' do
      let(:assigns) { { key: 'value' } }
      let(:options) { super().merge(assigns:) }

      it { expect(response.assigns).to be == assigns }
    end
  end

  describe '#call' do
    let(:renderer_flash) do
      instance_double(
        ActionDispatch::Flash::FlashHash,
        now: instance_double(ActionDispatch::Flash::FlashNow, '[]=': nil)
      )
    end
    let(:renderer) do
      instance_double(
        ActionController::Base,
        flash:                 renderer_flash,
        instance_variable_set: nil,
        render:                nil
      )
    end

    it { expect(response).to respond_to(:call).with(1).argument }

    it 'should render the template' do
      response.call(renderer)

      expect(renderer)
        .to have_received(:render)
        .with(template, status: 200)
    end

    context 'when initialized with assigns: a Hash' do
      let(:assigns) do
        {
          author: 'Tamsyn Muir',
          title:  'Gideon the Ninth'
        }
      end
      let(:options) { super().merge(assigns:) }

      it 'should assign the variables', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        response.call(renderer)

        assigns.each do |key, value|
          expect(renderer)
            .to have_received(:instance_variable_set)
            .with("@#{key}", value)
        end
      end

      it 'should render the template' do
        response.call(renderer)

        expect(renderer)
          .to have_received(:render)
          .with(template, status: 200)
      end
    end

    context 'when initialized with flash: a Hash' do
      let(:flash) do
        {
          alert:  'Reactor temperature critical',
          notice: 'Initializing activation sequence'
        }
      end
      let(:options) { super().merge(flash:) }

      it 'should assign the flash', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        response.call(renderer)

        flash.each do |key, value|
          expect(renderer_flash.now)
            .to have_received(:[]=)
            .with(key, value)
        end
      end

      it 'should render the template' do
        response.call(renderer)

        expect(renderer)
          .to have_received(:render)
          .with(template, status: 200)
      end
    end

    context 'when initialized with layout: value' do
      let(:layout)  { 'page' }
      let(:options) { super().merge(layout:) }

      it 'should render the template' do
        response.call(renderer)

        expect(renderer)
          .to have_received(:render)
          .with(template, layout:, status: 200)
      end
    end

    context 'when initialized with status: value' do
      let(:status)  { 201 }
      let(:options) { super().merge(status:) }

      it 'should render the template' do
        response.call(renderer)

        expect(renderer)
          .to have_received(:render)
          .with(template, status:)
      end
    end
  end

  describe '#flash' do
    include_examples 'should define reader', :flash, {}

    context 'when initialized with flash: a Hash' do
      let(:flash) do
        {
          alert:  'Reactor temperature critical',
          notice: 'Initializing activation sequence'
        }
      end
      let(:options) { super().merge(flash:) }

      it { expect(response.flash).to be == flash }
    end
  end

  describe '#layout' do
    include_examples 'should define reader', :layout, nil

    context 'when initialized with layout: value' do
      let(:layout)  { 'page' }
      let(:options) { super().merge(layout:) }

      it { expect(response.layout).to be == layout }
    end
  end

  describe '#status' do
    include_examples 'should define reader', :status, 200

    context 'when initialized with status: value' do
      let(:status)  { 201 }
      let(:options) { super().merge(status:) }

      it { expect(response.status).to be status }
    end
  end

  describe '#template' do
    include_examples 'should define reader', :template, -> { be == template }
  end
end
