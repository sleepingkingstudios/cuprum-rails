# frozen_string_literal: true

require 'cuprum/rails/responses/head_response'

RSpec.describe Cuprum::Rails::Responses::HeadResponse do
  subject(:response) { described_class.new(**constructor_options) }

  let(:status)              { 500 }
  let(:constructor_options) { { status: } }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:status)
    end
  end

  describe '#call' do
    let(:renderer) { instance_double(Spec::Renderer, head: nil) }

    example_class 'Spec::Renderer' do |klass|
      klass.define_method(:head) { |*, **| nil }
    end

    it { expect(response).to respond_to(:call).with(1).argument }

    it 'should delegate to the #head method' do
      response.call(renderer)

      expect(renderer).to have_received(:head).with(response.status)
    end
  end

  describe '#status' do
    include_examples 'should define reader', :status, 500
  end
end
