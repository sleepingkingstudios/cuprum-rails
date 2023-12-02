# frozen_string_literal: true

require 'cuprum/rails/errors/invalid_statement'

RSpec.describe Cuprum::Rails::Errors::InvalidStatement do
  subject(:error) { described_class.new(message: message) }

  let(:message) { 'invalid database statement' }

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.rails.errors.invalid_statement'
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:message)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {},
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should define reader', :as_json, -> { be == expected }
  end

  describe '#message' do
    include_examples 'should define reader', :message, -> { message }
  end

  describe '#type' do
    include_examples 'should define reader', :type, -> { described_class::TYPE }
  end
end
