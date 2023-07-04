# frozen_string_literal: true

require 'cuprum/collections/repository'
require 'cuprum/middleware'

require 'cuprum/rails/controllers/action'
require 'cuprum/rails/controllers/middleware'

RSpec.describe Cuprum::Rails::Controllers::Action do
  subject(:action) { described_class.new(**constructor_options) }

  let(:action_class)    { Cuprum::Rails::Action }
  let(:action_name)     { :process }
  let(:constructor_options) do
    {
      action_class: action_class,
      action_name:  action_name
    }
  end

  example_class 'Spec::JsonResponder'

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:action_class, :action_name, :member_action)
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
        action.call(controller, request)

        expect(responder_class)
          .to have_received(:new)
          .with(
            action_name:   action_name,
            controller:    controller,
            member_action: member_action,
            request:       request,
            serializers:   configured_serializers
          )
      end
    end

    let(:action_class)    { Spec::Action }
    let(:member_action)   { false }
    let(:middleware) { [] }
    let(:repository) { nil }
    let(:resource) do
      Cuprum::Rails::Resource.new(resource_name: 'books')
    end
    let(:responders) do
      { json: Spec::JsonResponder }
    end
    let(:configured_serializers) { {} }
    let(:configuration) do
      instance_double(
        Cuprum::Rails::Controllers::Configuration,
        middleware_for:  middleware,
        repository:      repository,
        resource:        resource,
        responders:      responders,
        serializers:     configured_serializers,
        serializers_for: configured_serializers
      )
    end
    let(:controller)      { Spec::CustomController.new }
    let(:result)          { Cuprum::Result.new }
    let(:implementation)  { Spec::Action.new(resource: resource) }
    let(:responder_class) { Spec::Responder }
    let(:response)        { instance_double(Spec::Response, call: nil) }
    let(:responder)       { instance_double(Spec::Responder, call: response) }
    let(:format)          { :json }
    let(:request) do
      instance_double(Cuprum::Rails::Request, format: format)
    end

    example_class 'Spec::Action', Cuprum::Rails::Action

    example_class 'Spec::CustomController' do |klass|
      klass.include(Cuprum::Rails::Controller)
    end

    example_class 'Spec::Responder', Cuprum::Rails::Responders::HtmlResponder

    example_class 'Spec::Response', Cuprum::Command

    before(:example) do
      allow(Spec::Action).to receive(:new).and_return(implementation)

      allow(Spec::Responder).to receive(:new).and_return(responder)

      allow(Spec::CustomController)
        .to receive(:configuration)
        .and_return(configuration)
      allow(Spec::CustomController)
        .to receive(:repository)
        .and_return(repository)
      allow(Spec::CustomController).to receive(:resource).and_return(resource)

      allow(configuration)
        .to receive(:responder_for)
        .with(format)
        .and_return(responder_class)

      allow(implementation).to receive(:call).and_return(result)
    end

    it 'should define the method' do
      expect(action).to respond_to(:call).with(2).arguments
    end

    it 'should build the action' do
      action.call(controller, request)

      expect(action_class)
        .to have_received(:new)
        .with(repository: nil, resource: resource)
    end

    it 'should call the action' do
      action.call(controller, request)

      expect(implementation).to have_received(:call).with(request: request)
    end

    include_examples 'should build the responder'

    it 'should call the responder' do
      action.call(controller, request)

      expect(responder).to have_received(:call).with(result)
    end

    it { expect(action.call(controller, request)).to be response }

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
        action.call(controller, request)

        expect(action_class)
          .to have_received(:new)
          .with(repository: repository, resource: resource)
      end

      it 'should call the action' do
        action.call(controller, request)

        expect(implementation).to have_received(:call).with(request: request)
      end

      it 'should call the middleware', :aggregate_failures do
        action.call(controller, request)

        expect(middleware_commands)
          .to all have_received(:call)
            .with(a_kind_of(Cuprum::Command), request: request)
      end

      it 'should call the middleware in sequence' do
        action.call(controller, request)

        expect(called_commands).to be == expected_commands
      end

      describe 'with middleware classes' do
        let(:middleware_commands) do
          [
            Spec::FirstMiddleware.new,
            Spec::SecondMiddleware.new(repository: repository),
            Spec::ThirdMiddleware.new(
              repository: repository,
              resource:   resource
            )
          ]
        end
        let(:middleware) do
          [
            instance_double(
              Cuprum::Rails::Controllers::Middleware,
              command: Spec::FirstMiddleware
            ),
            instance_double(
              Cuprum::Rails::Controllers::Middleware,
              command: Spec::SecondMiddleware
            ),
            instance_double(
              Cuprum::Rails::Controllers::Middleware,
              command: Spec::ThirdMiddleware
            )
          ]
        end

        example_class 'Spec::FirstMiddleware', 'Spec::Middleware'
        example_class 'Spec::SecondMiddleware', 'Spec::Middleware' do |klass|
          klass.define_method(:initialize) { |repository:| nil } # rubocop:disable Lint/UnusedBlockArgument
        end
        example_class 'Spec::ThirdMiddleware', 'Spec::Middleware' do |klass|
          klass.define_method(:initialize) { |**_| nil }
        end

        before(:example) do
          allow(Spec::FirstMiddleware)
            .to receive(:new)
            .and_return(middleware_commands[0])

          allow(Spec::SecondMiddleware)
            .to receive(:new)
            .and_return(middleware_commands[1])

          allow(Spec::ThirdMiddleware)
            .to receive(:new)
            .and_return(middleware_commands[2])
        end

        it 'should build the action' do
          action.call(controller, request)

          expect(action_class)
            .to have_received(:new)
            .with(repository: repository, resource: resource)
        end

        it 'should call the action' do
          action.call(controller, request)

          expect(implementation).to have_received(:call).with(request: request)
        end

        it 'should build the middleware', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
          action.call(controller, request)

          expect(Spec::FirstMiddleware).to have_received(:new).with(no_args)
          expect(Spec::SecondMiddleware)
            .to have_received(:new)
            .with(repository: repository)
          expect(Spec::ThirdMiddleware)
            .to have_received(:new)
            .with(repository: repository, resource: resource)
        end

        it 'should call the middleware', :aggregate_failures do
          action.call(controller, request)

          expect(middleware_commands)
            .to all have_received(:call)
              .with(a_kind_of(Cuprum::Command), request: request)
        end

        it 'should call the middleware in sequence' do
          action.call(controller, request)

          expect(called_commands).to be == expected_commands
        end

        context 'when the controller defines a repository' do
          let(:repository) { Cuprum::Collections::Repository.new }

          it 'should build the middleware', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
            action.call(controller, request)

            expect(Spec::FirstMiddleware).to have_received(:new).with(no_args)
            expect(Spec::SecondMiddleware)
              .to have_received(:new)
              .with(repository: repository)
            expect(Spec::ThirdMiddleware)
              .to have_received(:new)
              .with(repository: repository, resource: resource)
          end
        end
      end
    end

    context 'when the controller defines a repository' do
      let(:repository) { Cuprum::Collections::Repository.new }

      it 'should build the action' do
        action.call(controller, request)

        expect(action_class)
          .to have_received(:new)
          .with(repository: repository, resource: resource)
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
