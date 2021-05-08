# frozen_string_literal: true

require 'cuprum/rails/errors/undefined_permitted_attributes'

RSpec.describe Cuprum::Rails::Errors::UndefinedPermittedAttributes do
  subject(:error) { described_class.new(resource_name: resource_name) }

  let(:resource_name) { 'books' }

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.rails.errors.undefined_permitted_attributes'
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:resource_name)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => { 'resource_name' => resource_name },
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should define reader', :as_json, -> { be == expected }
  end

  describe '#message' do
    let(:expected) do
      "Resource #{resource_name.inspect} does not define" \
      ' permitted attributes'
    end

    include_examples 'should define reader', :message, -> { be == expected }
  end

  describe '#resource_name' do
    include_examples 'should define reader',
      :resource_name,
      -> { resource_name }
  end

  describe '#type' do
    include_examples 'should define reader', :type, -> { described_class::TYPE }
  end
end
