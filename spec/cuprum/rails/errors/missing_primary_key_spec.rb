# frozen_string_literal: true

require 'cuprum/rails/errors/missing_primary_key'

RSpec.describe Cuprum::Rails::Errors::MissingPrimaryKey do
  subject(:error) do
    described_class.new(
      primary_key:   primary_key,
      resource_name: resource_name
    )
  end

  let(:primary_key)   { :uuid }
  let(:resource_name) { 'tome' }

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.rails.errors.missing_primary_key'
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:primary_key, :resource_name)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {
          'primary_key'   => primary_key,
          'resource_name' => resource_name
        },
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should define reader', :as_json, -> { be == expected }
  end

  describe '#message' do
    let(:expected) do
      "Unable to find #{resource_name} because the #{primary_key.inspect}" \
        ' parameter is missing or empty'
    end

    include_examples 'should define reader', :message, -> { be == expected }
  end

  describe '#primary_key' do
    include_examples 'should define reader',
      :primary_key,
      -> { primary_key }
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
