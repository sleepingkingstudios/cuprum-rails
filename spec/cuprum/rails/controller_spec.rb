# frozen_string_literal: true

require 'cuprum/rails/controller'

RSpec.describe Cuprum::Rails::Controller do
  subject(:controller) { described_class.new(request) }

  let(:described_class) { Spec::Controller }
  let(:format)          { :html }
  let(:mime_type) do
    instance_double(Mime::Type, symbol: format)
  end
  let(:request) do
    instance_double(ActionDispatch::Request, format: mime_type)
  end

  example_class 'Spec::Controller', Struct.new(:request) do |klass|
    klass.include Cuprum::Rails::Controller # rubocop:disable RSpec/DescribedClass
  end

  describe '::UndefinedResourceError' do
    it { expect(described_class::UndefinedResourceError).to be_a Class }

    it { expect(described_class::UndefinedResourceError).to be < StandardError }
  end

  describe '::UnknownFormatError' do
    it { expect(described_class::UnknownFormatError).to be_a Class }

    it { expect(described_class::UnknownFormatError).to be < StandardError }
  end

  describe '.action' do
    shared_examples 'should define the action' do
      let(:expected) do
        {
          action_class:   Spec::Action,
          action_name:    action_name.intern,
          member_action?: false
        }
      end

      it 'should return the action name' do
        expect(described_class.action(action_name, Spec::Action))
          .to be action_name.intern
      end

      it 'should define the action' do
        described_class.action(action_name, Spec::Action)

        expect(described_class.actions[action_name.intern])
          .to be_a(Cuprum::Rails::ControllerAction)
          .and(have_attributes(**expected))
      end

      context 'with member: false' do
        it 'should define the action' do
          described_class.action(action_name, Spec::Action, member: false)

          expect(described_class.actions[action_name.intern])
            .to be_a(Cuprum::Rails::ControllerAction)
            .and(have_attributes(**expected))
        end
      end

      context 'with member: true' do
        let(:expected) { super().merge(member_action?: true) }

        it 'should define the action' do
          described_class.action(action_name, Spec::Action, member: true)

          expect(described_class.actions[action_name.intern])
            .to be_a(Cuprum::Rails::ControllerAction)
            .and(have_attributes(**expected))
        end
      end

      describe '#:action_name' do
        let(:action) { described_class.actions[action_name.intern] }

        before(:example) do
          described_class.action(action_name, Spec::Action)
        end

        it 'should define the method' do
          expect(controller).to respond_to(action_name.intern).with(0).arguments
        end

        context 'when the controller does not define a resource' do
          let(:error_message) do
            "no resource defined for #{described_class.name}"
          end

          it 'should raise an exception' do
            expect { controller.send(action_name) }
              .to raise_error(
                described_class::UndefinedResourceError,
                error_message
              )
          end
        end

        context 'when the controller does not define a responder' do
          let(:resource) { Cuprum::Rails::Resource.new(resource_name: 'books') }
          let(:error_message) do
            "no responder registered for format #{format.inspect}"
          end

          before(:example) do
            allow(controller) # rubocop:disable RSpec/SubjectStub
              .to receive(:resource)
              .and_return(resource)
          end

          it 'should raise an exception' do
            expect { controller.send(action_name) }
              .to raise_error(
                described_class::UnknownFormatError,
                error_message
              )
          end
        end

        context 'when the controller defines a resource and a responder' do
          let(:resource) { Cuprum::Rails::Resource.new(resource_name: 'books') }
          let(:response) { instance_double(Cuprum::Command, call: true) }

          example_class 'Spec::HtmlResponder'

          before(:example) do
            described_class.responder :html, Spec::HtmlResponder

            allow(controller) # rubocop:disable RSpec/SubjectStub
              .to receive(:resource)
              .and_return(resource)

            allow(action).to receive(:call).and_return(response)
          end

          it 'should call the action' do # rubocop:disable RSpec/ExampleLength
            controller.send(action_name)

            expect(action).to have_received(:call).with(
              request:         request,
              resource:        resource,
              responder_class: Spec::HtmlResponder
            )
          end

          it 'should call the response' do
            controller.send(action_name)

            expect(response).to have_received(:call).with(controller)
          end
        end
      end
    end

    example_class 'Spec::Action'

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:action)
        .with(2).arguments
        .and_keywords(:member)
    end

    describe 'with action_name: nil' do
      let(:error_message) { "action name can't be blank" }

      it 'should raise an exception' do
        expect { described_class.action(nil, Spec::Action) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with action_name: an Object' do
      let(:error_message) { 'action name must be a String or Symbol' }

      it 'should raise an exception' do
        expect { described_class.action(Object.new.freeze, Spec::Action) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with action_name: an empty String' do
      let(:error_message) { "action name can't be blank" }

      it 'should raise an exception' do
        expect { described_class.action('', Spec::Action) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with action_name: an empty Symbol' do
      let(:error_message) { "action name can't be blank" }

      it 'should raise an exception' do
        expect { described_class.action(:'', Spec::Action) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with action_name: a String' do
      let(:action_name) { 'process' }

      include_examples 'should define the action'
    end

    describe 'with action_name: a Symbol' do
      let(:action_name) { :process }

      include_examples 'should define the action'
    end

    describe 'with action_class: nil' do
      let(:error_message) { 'action class must be a Class' }

      it 'should raise an exception' do
        expect { described_class.action(:process, nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with action_class: an Object' do
      let(:error_message) { 'action class must be a Class' }

      it 'should raise an exception' do
        expect { described_class.action(:process, Object.new.freeze) }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '.actions' do
    include_examples 'should define class reader', :actions, -> { {} }

    context 'when the controller defines an action' do
      example_class 'Spec::PublishAction'

      before(:example) do
        described_class.action :publish, Spec::PublishAction, member: true
      end

      it { expect(described_class.actions).to have_key(:publish) }

      it 'should define the action' do # rubocop:disable RSpec/ExampleLength
        expect(described_class.actions[:publish])
          .to be_a(Cuprum::Rails::ControllerAction)
          .and(
            have_attributes(
              action_class:   Spec::PublishAction,
              action_name:    :publish,
              member_action?: true
            )
          )
      end
    end

    context 'with a controller subclass' do
      let(:described_class) { Spec::SubclassController }

      example_class 'Spec::PublishedAction'

      example_class 'Spec::SubclassController', 'Spec::Controller'

      before(:example) do
        Spec::Controller.action :published, Spec::PublishedAction
      end

      it { expect(described_class.actions).to have_key(:published) }

      it 'should define the action' do # rubocop:disable RSpec/ExampleLength
        expect(described_class.actions[:published])
          .to be_a(Cuprum::Rails::ControllerAction)
          .and(
            have_attributes(
              action_class:   Spec::PublishedAction,
              action_name:    :published,
              member_action?: false
            )
          )
      end

      context 'when the controller defines an action' do
        example_class 'Spec::PublishAction'

        before(:example) do
          described_class.action :publish, Spec::PublishAction, member: true
        end

        it { expect(described_class.actions).to have_key(:publish) }

        it { expect(described_class.actions).to have_key(:published) }

        it 'should define the publish action' do # rubocop:disable RSpec/ExampleLength
          expect(described_class.actions[:publish])
            .to be_a(Cuprum::Rails::ControllerAction)
            .and(
              have_attributes(
                action_class:   Spec::PublishAction,
                action_name:    :publish,
                member_action?: true
              )
            )
        end

        it 'should define the published action' do # rubocop:disable RSpec/ExampleLength
          expect(described_class.actions[:published])
            .to be_a(Cuprum::Rails::ControllerAction)
            .and(
              have_attributes(
                action_class:   Spec::PublishedAction,
                action_name:    :published,
                member_action?: false
              )
            )
        end
      end
    end
  end

  describe '.responder' do
    shared_examples 'should define the responder' do
      it 'should add the responder to .responders' do
        described_class.responder(format, Spec::Responder)

        expect(described_class.responders[format.intern])
          .to be Spec::Responder
      end
    end

    example_class 'Spec::Responder'

    it 'should define the class method' do
      expect(described_class).to respond_to(:responder).with(2).arguments
    end

    describe 'with format: nil' do
      let(:error_message) { "format can't be blank" }

      it 'should raise an exception' do
        expect { described_class.responder(nil, Spec::Responder) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with format: an Object' do
      let(:error_message) { 'format must be a String or Symbol' }

      it 'should raise an exception' do
        expect { described_class.responder(Object.new.freeze, Spec::Responder) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with format: an empty String' do
      let(:error_message) { "format can't be blank" }

      it 'should raise an exception' do
        expect { described_class.responder('', Spec::Responder) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with format: an empty Symbol' do
      let(:error_message) { "format can't be blank" }

      it 'should raise an exception' do
        expect { described_class.responder(:'', Spec::Responder) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with format: a String' do
      let(:format) { 'html' }

      include_examples 'should define the responder'
    end

    describe 'with format: a Symbol' do
      let(:format) { :html }

      include_examples 'should define the responder'
    end

    describe 'with responder_class: nil' do
      let(:error_message) { 'responder must be a Class' }

      it 'should raise an exception' do
        expect { described_class.responder(:html, nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with responder_class: an Object' do
      let(:error_message) { 'responder must be a Class' }

      it 'should raise an exception' do
        expect { described_class.responder(:html, Object.new.freeze) }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '.responders' do
    include_examples 'should define class reader', :responders, -> { {} }

    context 'when the controller defines a responder' do
      let(:expected) do
        {
          html: Spec::HtmlResponder,
          json: Spec::JsonResponder
        }
      end

      example_class 'Spec::HtmlResponder'

      example_class 'Spec::JsonResponder'

      before(:example) do
        described_class.responder :html, Spec::HtmlResponder

        described_class.responder :json, Spec::JsonResponder
      end

      it { expect(described_class.responders).to be == expected }
    end

    context 'with a controller subclass' do
      let(:described_class) { Spec::CustomController }
      let(:expected) do
        {
          html: Spec::HtmlResponder,
          json: Spec::JsonResponder
        }
      end

      example_class 'Spec::HtmlResponder'

      example_class 'Spec::JsonResponder'

      example_class 'Spec::CustomController', 'Spec::Controller'

      before(:example) do
        Spec::Controller.responder :html, Spec::HtmlResponder

        Spec::Controller.responder :json, Spec::JsonResponder
      end

      it { expect(described_class.responders).to be == expected }

      context 'when the controller defines a responder' do
        let(:expected) { super().merge(html: Spec::CustomResponder) }

        example_class 'Spec::CustomResponder'

        before(:example) do
          described_class.responder :html, Spec::CustomResponder
        end

        it { expect(described_class.responders).to be == expected }
      end
    end
  end

  describe '#resource' do
    let(:error_message) do
      "no resource defined for #{described_class.name}"
    end

    include_examples 'should define reader', :resource

    it 'should raise an exception' do
      expect { controller.resource }
        .to raise_error described_class::UndefinedResourceError, error_message
    end
  end

  describe '#responder_class' do
    let(:error_message) do
      "no responder registered for format #{format.inspect}"
    end

    include_examples 'should define reader', :responder_class

    it 'should raise an exception' do
      expect { controller.responder_class }
        .to raise_error described_class::UnknownFormatError, error_message
    end

    context 'when the controller defines a responder' do
      example_class 'Spec::HtmlResponder'

      example_class 'Spec::JsonResponder'

      before(:example) do
        described_class.responder :html, Spec::HtmlResponder

        described_class.responder :json, Spec::JsonResponder
      end

      it { expect(controller.responder_class).to be Spec::HtmlResponder }
    end

    context 'with a controller subclass' do
      let(:described_class) { Spec::CustomController }

      example_class 'Spec::HtmlResponder'

      example_class 'Spec::JsonResponder'

      example_class 'Spec::CustomController', 'Spec::Controller'

      before(:example) do
        Spec::Controller.responder :html, Spec::HtmlResponder

        Spec::Controller.responder :json, Spec::JsonResponder
      end

      it { expect(controller.responder_class).to be Spec::HtmlResponder }

      context 'when the controller defines a responder' do
        example_class 'Spec::CustomResponder'

        before(:example) do
          described_class.responder :html, Spec::CustomResponder
        end

        it { expect(controller.responder_class).to be Spec::CustomResponder }
      end
    end
  end
end
