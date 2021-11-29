# frozen_string_literal: true

require 'cuprum/collections/repository'
require 'cuprum/middleware'

require 'cuprum/rails/controllers/action'
require 'cuprum/rails/controllers/middleware'

RSpec.describe Cuprum::Rails::Controllers::Action do
  subject(:action) { described_class.new(configuration, **constructor_options) }

  let(:middleware) { [] }
  let(:repository) { nil }
  let(:resource)   { instance_double(Cuprum::Rails::Resource) }
  let(:responders) do
    { json: Spec::JsonResponder }
  end
  let(:configured_serializers) { {} }
  let(:configuration) do
    instance_double(
      Cuprum::Rails::Controllers::Configuration,
      middleware_for: middleware,
      repository:     repository,
      resource:       resource,
      responders:     responders,
      serializers:    configured_serializers
    )
  end
  let(:action_class) { Cuprum::Rails::Action }
  let(:action_name)  { :process }
  let(:constructor_options) do
    {
      action_class: action_class,
      action_name:  action_name
    }
  end

  example_class 'Spec::JsonResponder'

  describe '.new' do
    let(:expected_keywords) do
      %i[
        action_class
        action_name
        member_action
        serializers
      ]
    end

    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(1).argument
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
    shared_examples 'should build the responder' do
      it 'should build the responder' do # rubocop:disable RSpec/ExampleLength
        action.call(request)

        expect(responder_class)
          .to have_received(:new)
          .with(
            action_name:   action_name,
            member_action: member_action,
            resource:      resource,
            serializers:   expected_serializers
          )
      end
    end

    let(:resource) do
      Cuprum::Rails::Resource.new(resource_name: 'books')
    end
    let(:action_class)    { Spec::Action }
    let(:member_action)   { false }
    let(:result)          { Cuprum::Result.new }
    let(:implementation)  { Spec::Action.new(resource: resource) }
    let(:responder_class) { Spec::Responder }
    let(:response)        { instance_double(Spec::Response, call: nil) }
    let(:responder)       { instance_double(Spec::Responder, call: response) }
    let(:format)          { :json }
    let(:request) do
      instance_double(Cuprum::Rails::Request, format: format)
    end
    let(:expected_serializers) do
      if configured_serializers.key?(format)
        configured_serializers[format]
      else
        configured_serializers
      end
    end

    example_class 'Spec::Action', Cuprum::Rails::Action

    example_class 'Spec::Responder', Cuprum::Rails::Responders::HtmlResponder

    example_class 'Spec::Response', Cuprum::Command

    before(:example) do
      allow(Spec::Action).to receive(:new).and_return(implementation)

      allow(Spec::Responder).to receive(:new).and_return(responder)

      allow(configuration)
        .to receive(:responder_for)
        .with(format)
        .and_return(responder_class)

      allow(implementation).to receive(:call).and_return(result)
    end

    it 'should define the method' do
      expect(action).to respond_to(:call).with(1).argument
    end

    it 'should build the action' do
      action.call(request)

      expect(action_class)
        .to have_received(:new)
        .with(repository: nil, resource: resource)
    end

    it 'should call the action' do
      action.call(request)

      expect(implementation).to have_received(:call).with(request: request)
    end

    include_examples 'should build the responder'

    it 'should call the responder' do
      action.call(request)

      expect(responder).to have_received(:call).with(result)
    end

    it { expect(action.call(request)).to be response }

    context 'when initialized with member_action: true' do
      let(:member_action)       { true }
      let(:constructor_options) { super().merge(member_action: true) }

      include_examples 'should build the responder'
    end

    context 'when the controller defines middleware' do
      let(:middleware_commands) do
        Array.new(3) { Spec::Middleware.new }
      end
      let(:middleware) do
        middleware_commands.map do |command|
          instance_double(
            Cuprum::Rails::Controllers::Middleware,
            command: command
          )
        end
      end
      let(:expected_commands) { [*middleware_commands, implementation] }
      let(:called_commands)   { [] }

      example_class 'Spec::Middleware', 'Cuprum::Command' do |klass|
        klass.include Cuprum::Middleware
      end

      before(:example) do
        middleware_commands.each do |command|
          allow(command)
            .to receive(:call)
            .and_wrap_original do |original, next_command, request:|
              called_commands << command

              original.call(next_command, request: request)
            end
        end

        allow(implementation).to receive(:call) do
          called_commands << implementation
        end
      end

      it 'should build the action' do
        action.call(request)

        expect(action_class)
          .to have_received(:new)
          .with(repository: repository, resource: resource)
      end

      it 'should call the action' do
        action.call(request)

        expect(implementation).to have_received(:call).with(request: request)
      end

      it 'should call the middleware', :aggregate_failures do
        action.call(request)

        expect(middleware_commands)
          .to all have_received(:call)
            .with(a_kind_of(Cuprum::Command), request: request)
      end

      it 'should call the middleware in sequence' do
        action.call(request)

        expect(called_commands).to be == expected_commands
      end
    end

    context 'when the controller defines scoped serializers' do
      let(:configured_serializers) do
        {
          format => {
            Object   => Spec::BaseSerializer,
            NilClass => Spec::NullSerializer
          }
        }
      end

      example_class 'Spec::BaseSerializer'

      example_class 'Spec::NullSerializer'

      include_examples 'should build the responder'

      context 'when initialized with scoped serializers' do
        let(:serializers) do
          {
            json: { Object => Spec::JsonSerializer },
            yaml: { Object => Spec::YamlSerializer }
          }
        end
        let(:constructor_options) do
          super().merge(serializers: serializers)
        end
        let(:expected_serializers) do
          super().merge(serializers[format])
        end

        example_class 'Spec::JsonSerializer'
        example_class 'Spec::YamlSerializer'

        include_examples 'should build the responder'
      end

      context 'when initialized with unscoped serializers' do
        let(:serializers) { { Object => Spec::JsonSerializer } }
        let(:constructor_options) do
          super().merge(serializers: serializers)
        end
        let(:expected_serializers) do
          super().merge(serializers)
        end

        example_class 'Spec::JsonSerializer'

        include_examples 'should build the responder'
      end
    end

    context 'when the controller defines unscoped serializers' do
      let(:configured_serializers) do
        {
          Object   => Spec::BaseSerializer,
          NilClass => Spec::NullSerializer
        }
      end

      example_class 'Spec::BaseSerializer'

      example_class 'Spec::NullSerializer'

      include_examples 'should build the responder'

      context 'when initialized with scoped serializers' do
        let(:serializers) do
          {
            json: { Object => Spec::JsonSerializer },
            yaml: { Object => Spec::YamlSerializer }
          }
        end
        let(:constructor_options) do
          super().merge(serializers: serializers)
        end
        let(:expected_serializers) do
          super().merge(serializers[format])
        end

        example_class 'Spec::JsonSerializer'
        example_class 'Spec::YamlSerializer'

        include_examples 'should build the responder'
      end

      context 'when initialized with unscoped serializers' do
        let(:serializers) { { Object => Spec::JsonSerializer } }
        let(:constructor_options) do
          super().merge(serializers: serializers)
        end
        let(:expected_serializers) do
          super().merge(serializers)
        end

        example_class 'Spec::JsonSerializer'

        include_examples 'should build the responder'
      end
    end

    context 'when the controller defines a repository' do
      let(:repository) { Cuprum::Collections::Repository.new }

      it 'should build the action' do
        action.call(request)

        expect(action_class)
          .to have_received(:new)
          .with(repository: repository, resource: resource)
      end
    end
  end

  describe '#configuration' do
    include_examples 'should define reader',
      :configuration,
      -> { configuration }
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

  describe '#repository' do
    include_examples 'should define reader', :repository, nil

    context 'when the controller defines a repository' do
      let(:repository) { Cuprum::Collections::Repository.new }

      it { expect(action.repository).to be repository }
    end
  end

  describe '#resource' do
    include_examples 'should define reader', :resource, -> { resource }
  end

  describe '#responder_for' do
    before(:example) do
      allow(configuration)
        .to receive(:responder_for)
        .with(:json)
        .and_return(Spec::JsonResponder)
    end

    it { expect(action).to respond_to(:responder_for).with(1).argument }

    it { expect(action.responder_for(:json)).to be Spec::JsonResponder }
  end

  describe '#serializers' do
    include_examples 'should define reader', :serializers, -> { {} }

    context 'when initialized with scoped serializers' do
      let(:serializers) do
        {
          json: { Object => Spec::JsonSerializer },
          yaml: { Object => Spec::YamlSerializer }
        }
      end
      let(:constructor_options) do
        super().merge(serializers: serializers)
      end

      example_class 'Spec::JsonSerializer'
      example_class 'Spec::YamlSerializer'

      it { expect(action.serializers).to be == serializers }
    end

    context 'when initialized with unscoped serializers' do
      let(:serializers) { { Object => Spec::JsonSerializer } }
      let(:constructor_options) do
        super().merge(serializers: serializers)
      end

      example_class 'Spec::JsonSerializer'

      it { expect(action.serializers).to be == serializers }
    end
  end
end
