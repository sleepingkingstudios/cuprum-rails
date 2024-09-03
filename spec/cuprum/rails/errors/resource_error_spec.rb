# frozen_string_literal: true

require 'cuprum/rails/errors/resource_error'

require 'support/book'

RSpec.describe Cuprum::Rails::Errors::ResourceError do
  subject(:error) do
    described_class.new(resource:, **options)
  end

  let(:resource) { Cuprum::Rails::Resource.new(name: 'books') }
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
            'entity_class'   => resource.entity_class.to_s,
            'name'           => resource.name.to_s,
            'qualified_name' => resource.qualified_name.to_s,
            'singular'       => resource.singular?,
            'singular_name'  => resource.singular_name.to_s
          }
        },
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should define reader', :as_json, -> { be == expected }

    context 'when initialized with message: value' do
      let(:message) { "permitted attributes can't be blank" }
      let(:options) { super().merge(message:) }

      it { expect(error.as_json).to be == expected }
    end
  end

  describe '#message' do
    let(:expected) { "invalid resource #{resource.name}" }

    it { expect(error.message).to be == expected }

    context 'when initialized with message: value' do
      let(:message) { "permitted attributes can't be blank" }
      let(:options) { super().merge(message:) }
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
