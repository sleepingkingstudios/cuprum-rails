# frozen_string_literal: true

require 'cuprum/rails/errors/missing_parameter'

RSpec.describe Cuprum::Rails::Errors::MissingParameter do
  subject(:error) do
    described_class.new(parameter_name: parameter_name, parameters: parameters)
  end

  let(:parameter_name) { 'author_id' }
  let(:parameters)     { { 'order' => 'title', 'page' => '3' } }

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.rails.errors.missing_parameter'
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:parameter_name, :parameters)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {
          'parameter_name' => parameter_name,
          'parameters'     => parameters
        },
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should define reader', :as_json, -> { be == expected }
  end

  describe '#message' do
    let(:expected) { "missing parameter #{parameter_name.inspect}" }

    it { expect(error.message).to be == expected }
  end

  describe '#type' do
    include_examples 'should define reader', :type, -> { described_class::TYPE }
  end
end
