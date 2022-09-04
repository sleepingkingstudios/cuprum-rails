# frozen_string_literal: true

require 'stannum/errors'

require 'cuprum/rails/errors/invalid_parameters'

RSpec.describe Cuprum::Rails::Errors::InvalidParameters do
  subject(:error) { described_class.new(errors: errors) }

  let(:errors) do
    Stannum::Errors
      .new
      .tap { |err| err['title'].add('spec.error', message: "can't be blank") }
  end

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.rails.errors.invalid_parameters'
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:errors)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => { 'errors' => errors.group_by_path },
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should define reader', :as_json, -> { be == expected }
  end

  describe '#errors' do
    include_examples 'should define reader', :errors, -> { errors }
  end

  describe '#message' do
    let(:expected) { "invalid request parameters - #{errors.summary}" }

    it { expect(error.message).to be == expected }
  end

  describe '#type' do
    include_examples 'should define reader', :type, -> { described_class::TYPE }
  end
end
