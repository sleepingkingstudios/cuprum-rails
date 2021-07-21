# frozen_string_literal: true

require 'cuprum/rails/controller_action'

RSpec.describe Cuprum::Rails::ControllerAction do
  subject(:action) { described_class.new(**constructor_options) }

  let(:action_class) { Cuprum::Rails::Action }
  let(:action_name)  { :process }
  let(:constructor_options) do
    {
      action_class: action_class,
      action_name:  action_name
    }
  end

  describe '.new' do
    let(:expected_keywords) do
      %i[
        action_class
        action_name
        member_action
      ]
    end

    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(*expected_keywords)
    end
  end

  describe '#action_class' do
    include_examples 'should define reader', :action_class, -> { action_class }
  end

  describe '#action_name' do
    include_examples 'should define reader', :action_name, -> { action_name }
  end

  describe '#call' do
    let(:resource) do
      Cuprum::Rails::Resource.new(resource_name: 'books')
    end
    let(:action_class)    { Spec::Action }
    let(:result)          { Cuprum::Result.new }
    let(:implementation)  { instance_double(Spec::Action, call: result) }
    let(:responder_class) { Spec::Responder }
    let(:response)        { instance_double(Spec::Response, call: nil) }
    let(:responder)       { instance_double(Spec::Responder, call: response) }
    let(:format)          { :html }
    let(:mime_type) do
      instance_double(Mime::Type, symbol: format)
    end
    let(:request) do
      instance_double(ActionDispatch::Request, format: mime_type)
    end

    def call_action
      action.call(
        request:         request,
        resource:        resource,
        responder_class: responder_class
      )
    end

    example_class 'Spec::Action', Cuprum::Rails::Action

    example_class 'Spec::Responder', Cuprum::Rails::Responders::HtmlResponder

    example_class 'Spec::Response', Cuprum::Command

    before(:example) do
      allow(Spec::Action).to receive(:new).and_return(implementation)

      allow(Spec::Responder).to receive(:new).and_return(responder)
    end

    it 'should define the method' do
      expect(action)
        .to respond_to(:call)
        .with(0).arguments
        .and_keywords(:request, :resource, :responder_class)
    end

    it 'should build the action' do
      call_action

      expect(action_class).to have_received(:new).with(resource: resource)
    end

    it 'should call the action' do
      call_action

      expect(implementation).to have_received(:call).with(request: request)
    end

    it 'should build the responder' do # rubocop:disable RSpec/ExampleLength
      call_action

      expect(responder_class)
        .to have_received(:new)
        .with(
          action_name:   action_name,
          member_action: false,
          resource:      resource
        )
    end

    it 'should call the responder' do
      call_action

      expect(responder).to have_received(:call).with(result)
    end

    it { expect(call_action).to be response }

    context 'when initialized with member_action: true' do
      let(:constructor_options) { super().merge(member_action: true) }

      it 'should build the responder' do # rubocop:disable RSpec/ExampleLength
        call_action

        expect(responder_class)
          .to have_received(:new)
          .with(
            action_name:   action_name,
            member_action: true,
            resource:      resource
          )
      end
    end
  end

  describe '#member_action?' do
    include_examples 'should define predicate', :member_action?, false

    context 'when initialized with member_action: false' do
      let(:constructor_options) { super().merge(member_action: false) }

      it { expect(action.member_action?).to be false }
    end

    context 'when initialized with member_action: true' do
      let(:constructor_options) { super().merge(member_action: true) }

      it { expect(action.member_action?).to be true }
    end
  end
end
