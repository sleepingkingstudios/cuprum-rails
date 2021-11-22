# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'support/examples'

module Spec::Support::Examples
  module ControllerExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'with a native request' do
      let(:format) { :html }
      let(:native_request) do
        instance_double(
          ActionDispatch::Request,
          authorization:         nil,
          format:                instance_double(Mime::Type, symbol: format),
          fullpath:              '/books',
          headers:               { 'HTTP_HOST' => 'www.example.com' },
          params:                { 'key' => 'value', 'param' => 'value' },
          query_parameters:      { 'param' => 'value' },
          request_method_symbol: :get,
          request_parameters:    { 'key' => 'value' }
        )
      end
      let(:request) { Cuprum::Rails::Request.build(request: native_request) }

      before(:example) do
        allow(Cuprum::Rails::Request)
          .to receive(:build)
          .and_return(request)
      end
    end

    shared_examples 'should implement the actions DSL' do
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
              .to be_a(Cuprum::Rails::Controllers::Action)
              .and(have_attributes(**expected))
          end

          context 'with member: false' do
            it 'should define the action' do
              described_class.action(action_name, Spec::Action, member: false)

              expect(described_class.actions[action_name.intern])
                .to be_a(Cuprum::Rails::Controllers::Action)
                .and(have_attributes(**expected))
            end
          end

          context 'with member: true' do
            let(:expected) { super().merge(member_action?: true) }

            it 'should define the action' do
              described_class.action(action_name, Spec::Action, member: true)

              expect(described_class.actions[action_name.intern])
                .to be_a(Cuprum::Rails::Controllers::Action)
                .and(have_attributes(**expected))
            end
          end

          describe '#:action_name' do
            let(:action) { described_class.actions[action_name.intern] }

            before(:example) do
              described_class.action(action_name, Spec::Action)
            end

            it 'should define the method' do
              expect(controller)
                .to respond_to(action_name.intern)
                .with(0).arguments
            end

            context 'when the controller does not define a resource' do
              let(:error_class) do
                Cuprum::Rails::Controller::UndefinedResourceError
              end
              let(:error_message) do
                "no resource defined for #{described_class.name}"
              end

              example_class 'Spec::HtmlResponder'

              before(:example) do
                described_class.responder :html, Spec::HtmlResponder
              end

              it 'should raise an exception' do
                expect { controller.send(action_name) }
                  .to raise_error(error_class, error_message)
              end
            end

            context 'when the controller does not define a responder' do
              let(:resource) do
                Cuprum::Rails::Resource.new(resource_name: 'books')
              end
              let(:error_class) do
                Cuprum::Rails::Controller::UnknownFormatError
              end
              let(:error_message) do
                "no responder registered for format #{format.inspect}"
              end

              before(:example) do
                allow(described_class)
                  .to receive(:resource)
                  .and_return(resource)
              end

              it 'should raise an exception' do
                expect { controller.send(action_name) }
                  .to raise_error(error_class, error_message)
              end
            end

            context 'when the controller defines a resource and a responder' do
              let(:resource) do
                Cuprum::Rails::Resource.new(resource_name: 'books')
              end
              let(:response) { instance_double(Cuprum::Command, call: true) }

              example_class 'Spec::HtmlResponder'

              before(:example) do
                described_class.responder :html, Spec::HtmlResponder

                allow(described_class)
                  .to receive(:resource)
                  .and_return(resource)

                allow(action).to receive(:call).and_return(response)
              end

              it 'should build the request' do # rubocop:disable RSpec/ExampleLength
                controller.send(action_name)

                expect(Cuprum::Rails::Request)
                  .to have_received(:build)
                  .with(
                    action_name:     action_name.intern,
                    controller_name: controller.controller_name,
                    request:         native_request
                  )
              end

              it 'should call the action' do
                controller.send(action_name)

                expect(action).to have_received(:call).with(request)
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
              .to be_a(Cuprum::Rails::Controllers::Action)
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
              .to be_a(Cuprum::Rails::Controllers::Action)
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
                .to be_a(Cuprum::Rails::Controllers::Action)
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
                .to be_a(Cuprum::Rails::Controllers::Action)
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
    end

    shared_examples 'should implement the configuration DSL' do
      shared_context 'when the controller defines a resource' do
        let(:resource) { Spec::Resource.new }

        example_class 'Spec::Resource'

        before(:example) do
          value = resource

          described_class.define_singleton_method(:resource) { value }
        end
      end

      shared_context 'when the controller defines responders' do
        example_class 'Spec::HtmlResponder'

        example_class 'Spec::JsonResponder'

        before(:example) do
          described_class.responder :html, Spec::HtmlResponder

          described_class.responder :json, Spec::JsonResponder
        end
      end

      describe '.configuration' do
        include_examples 'should define class reader', :configuration

        it 'should return the controller configuration' do
          expect(described_class.configuration)
            .to be_a Cuprum::Rails::Controllers::Configuration
        end

        it 'should delegate to the controller' do
          expect(described_class.configuration.controller)
            .to be described_class
        end

        wrap_context 'when the controller defines a resource' do
          it 'should return the controller configuration' do
            expect(described_class.configuration)
              .to be_a Cuprum::Rails::Controllers::Configuration
          end

          it 'should delegate to the controller' do
            expect(described_class.configuration.controller)
              .to be described_class
          end

          it 'should return the configured resource' do
            expect(described_class.configuration.resource)
              .to be == described_class.resource
          end

          it 'should return the configured responders' do
            expect(described_class.configuration.responders)
              .to be == described_class.responders
          end

          it 'should return the configured serializers' do
            expect(described_class.configuration.serializers)
              .to be == described_class.serializers
          end

          wrap_context 'when the controller defines responders' do
            it 'should return the configured responders' do
              expect(described_class.configuration.responders)
                .to be == described_class.responders
            end
          end
        end
      end

      describe '.resource' do
        let(:error_class) do
          Cuprum::Rails::Controller::UndefinedResourceError
        end
        let(:error_message) do
          "no resource defined for #{described_class.name}"
        end

        include_examples 'should define class reader', :resource

        it 'should raise an exception' do
          expect { described_class.resource }
            .to raise_error error_class, error_message
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
            expect do
              described_class.responder(Object.new.freeze, Spec::Responder)
            end
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

        wrap_context 'when the controller defines responders' do
          let(:expected) do
            {
              html: Spec::HtmlResponder,
              json: Spec::JsonResponder
            }
          end

          it { expect(described_class.responders).to be == expected }
        end
      end

      describe '.serializers' do
        let(:expected) do
          {
            json: Cuprum::Rails::Serializers::Json.default_serializers
          }
        end

        include_examples 'should define class reader',
          :serializers,
          -> { be == expected }
      end
    end

    shared_examples 'should implement the middleware DSL' do
      shared_context 'when the controller defines middleware' do
        let(:middleware) do
          [
            {
              command: Spec::Middleware,
              except:  [],
              only:    []
            },
            {
              command: Cuprum::Command.new,
              except:  %i[destroy],
              only:    []
            },
            {
              command: Cuprum::Command.new,
              except:  [],
              only:    %i[index show]
            }
          ]
        end

        before(:example) do
          middleware.each do |hsh|
            described_class.middleware(
              hsh[:command],
              except: hsh[:except],
              only:   hsh[:only]
            )
          end
        end
      end

      describe '#middleware' do
        shared_examples 'should define the middleware' do
          describe 'with command: a command instance' do
            let(:command) { Spec::Middleware.new }
            let(:options) { {} }
            let(:configured_middleware) do
              super() + [
                {
                  command: command,
                  except:  options.fetch(:except, []),
                  only:    options.fetch(:only,   [])
                }
              ]
            end

            it 'should define the middleware' do
              expect(described_class.middleware(command, **options))
                .to be == expected
            end

            describe 'with except: value' do
              let(:excepted_actions) { %i[index show] }
              let(:options)          { super().merge(except: excepted_actions) }

              it 'should define the middleware' do
                expect(described_class.middleware(command, **options))
                  .to be == expected
              end
            end

            describe 'with only: value' do
              let(:only_actions) { %i[create update] }
              let(:options)      { super().merge(only: only_actions) }

              it 'should define the middleware' do
                expect(described_class.middleware(command, **options))
                  .to be == expected
              end
            end
          end

          describe 'with command: a command class' do
            let(:command) { Spec::Middleware }
            let(:options) { {} }
            let(:configured_middleware) do
              super() + [
                {
                  command: command.new,
                  except:  options.fetch(:except, []),
                  only:    options.fetch(:only,   [])
                }
              ]
            end

            it 'should define the middleware' do
              expect(described_class.middleware(command, **options))
                .to be == expected
            end

            describe 'with except: value' do
              let(:excepted_actions) { %i[index show] }
              let(:options)          { super().merge(except: excepted_actions) }

              it 'should define the middleware' do
                expect(described_class.middleware(command, **options))
                  .to be == expected
              end
            end

            describe 'with only: value' do
              let(:only_actions) { %i[create update] }
              let(:options)      { super().merge(only: only_actions) }

              it 'should define the middleware' do
                expect(described_class.middleware(command, **options))
                  .to be == expected
              end
            end
          end
        end

        let(:configured_middleware) { [] }
        let(:expected) do
          configured_middleware.map do |hsh|
            command = hsh[:command]
            command = command.new if command.is_a?(Class)

            Cuprum::Rails::Controllers::Middleware.new(
              command: command,
              except:  hsh[:except],
              only:    hsh[:only]
            )
          end
        end

        example_class 'Spec::Middleware', 'Cuprum::Command' do |klass|
          klass.define_method(:==) { |other| other.is_a?(Spec::Middleware) }
        end

        it 'should define the class method' do
          expect(described_class)
            .to respond_to(:middleware)
            .with(0..1).arguments
            .and_keywords(:except, :only)
        end

        it { expect(described_class.middleware).to be == [] }

        include_examples 'should define the middleware'

        describe 'with command: an object' do
          let(:error_message) do
            'command must be an instance of or subclass of Cuprum::Command'
          end

          it 'should raise an exception' do
            expect { described_class.middleware Object.new.freeze }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with except: an object' do
          let(:command) { Cuprum::Command.new }
          let(:error_message) do
            'except must be a list of action names'
          end

          it 'should raise an exception' do
            expect do
              described_class.middleware command, except: Object.new.freeze
            end
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with except: an invalid array' do
          let(:command) { Cuprum::Command.new }
          let(:error_message) do
            'except must be a list of action names'
          end

          it 'should raise an exception' do
            expect do
              described_class.middleware command, except: [nil]
            end
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with only: an object' do
          let(:command) { Cuprum::Command.new }
          let(:error_message) do
            'only must be a list of action names'
          end

          it 'should raise an exception' do
            expect do
              described_class.middleware command, only: Object.new.freeze
            end
              .to raise_error ArgumentError, error_message
          end
        end

        wrap_context 'when the controller defines middleware' do
          let(:configured_middleware) { middleware }

          it { expect(described_class.middleware).to be == expected }

          include_examples 'should define the middleware'
        end

        context 'with a controller subclass' do
          let(:described_class) { Spec::SubclassController }

          example_class 'Spec::SubclassController', 'Spec::Controller'

          it { expect(described_class.middleware).to be == [] }

          include_examples 'should define the middleware'

          wrap_context 'when the controller defines middleware' do
            let(:configured_middleware) { middleware }

            it { expect(described_class.middleware).to be == expected }

            include_examples 'should define the middleware'
          end

          context 'when the subclass defines middleware' do
            let(:subclass_middleware) do
              [
                {
                  command: Spec::Middleware,
                  except:  [],
                  only:    %i[drafts published]
                }
              ]
            end
            let(:configured_middleware) { subclass_middleware }

            before(:example) do
              subclass_middleware.each do |hsh|
                Spec::Controller.middleware(
                  hsh[:command],
                  except: hsh[:except],
                  only:   hsh[:only]
                )
              end
            end

            it { expect(described_class.middleware).to be == expected }

            include_examples 'should define the middleware'

            wrap_context 'when the controller defines middleware' do
              let(:configured_middleware) { super() + middleware }

              it { expect(described_class.middleware).to be == expected }

              include_examples 'should define the middleware'
            end
          end
        end
      end
    end
  end
end
