# frozen_string_literal: true

require 'cuprum/rails/errors/resource_error'

require 'support/book'

RSpec.describe Cuprum::Rails::Errors::ResourceError do
  subject(:error) do
    described_class.new(resource: resource, **options)
  end

  let(:resource) { Cuprum::Rails::Resource.new(resource_name: 'books') }
  let(:options)  { {} }

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.rails.errors.resource_error'
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:message, :resource)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {
          'resource' => {
            'resource_class' => resource.resource_class.to_s,
            'resource_name'  => resource.resource_name.to_s,
            'singular'       => resource.singular?
          }
        },
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should define reader', :as_json, -> { be == expected }

    context 'when initialized with message: value' do
      let(:message) { "permitted attributes can't be blank" }
      let(:options) { super().merge(message: message) }

      it { expect(error.as_json).to be == expected }
    end
  end

  describe '#message' do
    let(:expected) { "invalid resource #{resource.resource_name}" }

    it { expect(error.message).to be == expected }

    context 'when initialized with message: value' do
      let(:message) { "permitted attributes can't be blank" }
      let(:options) { super().merge(message: message) }
      let(:expected) do
        "#{super()} - #{message}"
      end

      it { expect(error.message).to be == expected }
    end
  end

  describe '#resource' do
    include_examples 'should define reader', :resource, -> { resource }
  end

  describe '#type' do
    include_examples 'should define reader', :type, -> { described_class::TYPE }
  end
end
