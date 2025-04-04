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
        .and_keywords(:fallback_location, :flash, :status)
    end
  end

  describe '#call' do
    shared_examples 'should redirect back' do
      it 'should call #redirect_back_or_to' do
        response.call(renderer)

        expect(renderer)
          .to have_received(:redirect_back_or_to)
          .with(fallback_location, status:)
      end
    end

    let(:renderer_flash) do
      instance_double(
        ActionDispatch::Flash::FlashHash,
        '[]=': nil
      )
    end
    let(:renderer) do
      instance_double(
        ActionController::Base,
        flash:               renderer_flash,
        redirect_back_or_to: nil
      )
    end
    let(:fallback_location) { '/' }
    let(:status)            { 302 }

    it { expect(response).to respond_to(:call).with(1).argument }

    include_examples 'should redirect back'

    context 'when initialized with fallback_location: value' do
      let(:fallback_location) do
        '/path/to/resource'
      end
      let(:options) { super().merge(fallback_location:) }

      include_examples 'should redirect back'
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
          expect(renderer_flash)
            .to have_received(:[]=)
            .with(key, value)
        end
      end

      include_examples 'should redirect back'
    end

    context 'when initialized with status: value' do
      let(:status)  { 303 }
      let(:options) { super().merge(status:) }

      include_examples 'should redirect back'
    end
  end

  describe '#fallback_location' do
    include_examples 'should define reader', :fallback_location, '/'

    context 'when initialized with fallback_location: value' do
      let(:options) { super().merge(fallback_location: '/path/to/resource') }

      it { expect(response.fallback_location).to be == '/path/to/resource' }
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

  describe '#status' do
    include_examples 'should define reader', :status, 302

    context 'when initialized with status: value' do
      let(:options) { super().merge(status: 303) }

      it { expect(response.status).to be 303 }
    end
  end
end
