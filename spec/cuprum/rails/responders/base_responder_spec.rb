# frozen_string_literal: true

require 'cuprum/rails/responders/base_responder'

RSpec.describe Cuprum::Rails::Responders::BaseResponder do
  subject(:responder) { described_class.new(**constructor_options) }

  let(:action_name) { :published }
  let(:resource)    { Cuprum::Rails::Resource.new(resource_name: 'books') }
  let(:constructor_options) do
    {
      action_name: action_name,
      resource:    resource
    }
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:action_name, :member_action, :resource)
        .and_any_keywords
    end
  end

  describe '#action_name' do
    include_examples 'should define reader', :action_name, -> { action_name }
  end

  describe '#call' do
    let(:result) { Cuprum::Result.new(value: :ok) }

    it { expect(responder).to respond_to(:call).with(1).argument }

    it 'should set the result' do
      expect { responder.call(result) }
        .to change(responder, :result)
        .to be == result
    end
  end

  describe '#member_action?' do
    include_examples 'should define predicate', :member_action?, false

    context 'when initialized with member_action: true' do
      let(:constructor_options) { super().merge(member_action: true) }

      it { expect(responder.member_action?).to be true }
    end
  end

  describe '#resource' do
    include_examples 'should define reader', :resource, -> { resource }
  end

  describe '#result' do
    include_examples 'should define reader', :result, nil
  end
end
