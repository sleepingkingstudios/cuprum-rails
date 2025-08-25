# frozen_string_literal: true

require 'cuprum/rails/responders/html_responder'
require 'cuprum/rails/rspec/deferred/responder_examples'

RSpec.describe Cuprum::Rails::Responders::HtmlResponder do
  include Cuprum::Rails::RSpec::Deferred::ResponderExamples

  subject(:responder) { described_class.new(**constructor_options) }

  let(:constructor_options) do
    {
      action_name:,
      controller:,
      request:
    }
  end

  it { expect(described_class).to be < Cuprum::Rails::Responders::Actions }

  it { expect(described_class).to be < Cuprum::Rails::Responders::Matching }

  it 'should include the rendering methods' do
    expect(described_class).to be < Cuprum::Rails::Responders::Html::Rendering
  end

  include_deferred 'should implement the Responder methods',
    constructor_keywords: %i[matcher]

  describe '#call' do
    let(:described_class) { Spec::HtmlResponder }

    example_class 'Spec::HtmlResponder',
      Cuprum::Rails::Responders::HtmlResponder # rubocop:disable RSpec/DescribedClass

    it { expect(responder).to respond_to(:call).with(1).argument }

    describe 'with nil' do
      let(:error_message) { 'result must be a Cuprum::Result' }

      it 'should raise an exception' do
        expect { responder.call(nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      let(:error_message) { 'result must be a Cuprum::Result' }

      it 'should raise an exception' do
        expect { responder.call(Object.new.freeze) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a failing result' do
      let(:error)  { Cuprum::Error.new(message: 'Something went wrong.') }
      let(:result) { Cuprum::Result.new(status: :failure, error:) }

      include_deferred 'should redirect to', -> { resource.routes.index_path }

      context 'when initialized with member_action: false' do
        let(:constructor_options) { super().merge(member_action: false) }

        include_deferred 'should redirect to', -> { resource.base_path }
      end

      context 'when initialized with member_action: true' do
        let(:constructor_options) { super().merge(member_action: false) }

        include_deferred 'should redirect to', -> { resource.base_path }

        context 'when the resource defines routes' do
          let(:routes) do
            Cuprum::Rails::Routing::PluralRoutes.new(base_path: '/tomes')
          end
          let(:resource) do
            Cuprum::Rails::Resource.new(name: 'books', routes:)
          end

          include_deferred 'should redirect to',
            -> { resource.routes.index_path }

          # rubocop:disable RSpec/NestedGroups
          context 'when the result value exists' do
            let(:value) { Spec::Model.new('12345') }
            let(:result) do
              Cuprum::Result.new(
                status: :failure,
                error:,
                value:
              )
            end

            example_class 'Spec::Model', Struct.new(:id) do |klass|
              klass.define_singleton_method(:primary_key) { :id }
            end

            include_deferred 'should redirect to',
              -> { resource.routes.show_path(value) }
          end

          context 'when the result value is an empty Hash' do
            let(:result) do
              Cuprum::Result.new(
                status: :failure,
                error:,
                value:  {}
              )
            end

            include_deferred 'should redirect to',
              -> { resource.routes.index_path }
          end

          context 'when the result value is a Hash' do
            let(:value) { Spec::Model.new('12345') }
            let(:result) do
              Cuprum::Result.new(
                status: :failure,
                error:,
                value:  { 'book' => value }
              )
            end

            example_class 'Spec::Model', Struct.new(:id) do |klass|
              klass.define_singleton_method(:primary_key) { :id }
            end

            include_deferred 'should redirect to',
              -> { resource.routes.show_path(value) }
          end
          # rubocop:enable RSpec/NestedGroups
        end
      end

      context 'when the resource has ancestors' do
        let(:authors_resource) do
          Cuprum::Rails::Resource.new(name: 'authors')
        end
        let(:resource_options) { super().merge(parent: authors_resource) }
        let(:path_params)      { { 'author_id' => 0 } }
        let(:request) do
          Cuprum::Rails::Request.new(path_params:)
        end
        let(:expected_path) do
          resource.routes.with_wildcards(path_params).index_path
        end

        include_deferred 'should redirect to', -> { expected_path }
      end
    end

    describe 'with a passing result' do
      let(:result) { Cuprum::Result.new(status: :success) }

      include_deferred 'should render template', -> { action_name }

      context 'when the result value exists' do
        let(:result) { Cuprum::Result.new(status: :success, value: :ok) }

        include_deferred 'should render template',
          -> { action_name },
          assigns: -> { { value: :ok } }
      end

      context 'when the result value is an empty Hash' do
        let(:result) { Cuprum::Result.new(status: :success, value: {}) }

        include_deferred 'should render template',
          -> { action_name }
      end

      context 'when the result value is a Hash' do
        let(:value) do
          { 'book' => Struct.new(:title).new('Gideon the Ninth') }
        end
        let(:result) { Cuprum::Result.new(status: :success, value:) }

        include_deferred 'should render template',
          -> { action_name },
          assigns: -> { value }
      end
    end

    context 'when initialized with matcher: a matcher' do
      let(:matcher) do
        Cuprum::Matcher.new do
          match(:failure) { 'matcher: failure' }
        end
      end
      let(:constructor_options) { super().merge(matcher:) }

      describe 'with a failing result' do
        let(:result) { Cuprum::Result.new(status: :failure) }

        it { expect(responder.call(result)).to be == 'matcher: failure' }
      end

      describe 'with a passing result' do
        let(:result) { Cuprum::Result.new(status: :success) }
        let(:response_class) do
          Cuprum::Rails::Responses::Html::RenderResponse
        end

        it { expect(responder.call(result)).to be_a response_class }
      end
    end

    context 'when the responder defines actions' do
      before(:example) do
        Spec::HtmlResponder.action(:process) do
          match(:failure) { 'action: failure' }
        end
      end

      describe 'with a non-matching action name' do
        describe 'with a failing result' do
          let(:result) { Cuprum::Result.new(status: :failure) }
          let(:response_class) do
            Cuprum::Rails::Responses::Html::RedirectResponse
          end

          it { expect(responder.call(result)).to be_a response_class }
        end

        describe 'with a passing result' do
          let(:result) { Cuprum::Result.new(status: :success) }
          let(:response_class) do
            Cuprum::Rails::Responses::Html::RenderResponse
          end

          it { expect(responder.call(result)).to be_a response_class }
        end
      end

      describe 'with a matching action name' do
        let(:action_name) { :process }
        let(:result)      { Cuprum::Result.new(status: :failure) }

        describe 'with a failing result' do
          it { expect(responder.call(result)).to be == 'action: failure' }
        end

        describe 'with a passing result' do
          let(:result) { Cuprum::Result.new(status: :success) }
          let(:response_class) do
            Cuprum::Rails::Responses::Html::RenderResponse
          end

          it { expect(responder.call(result)).to be_a response_class }
        end
      end
    end

    context 'when the responder defines matches' do
      before(:example) do
        Spec::HtmlResponder.match(:failure, error: Spec::CustomError) do
          'responder: failure with error'
        end
      end

      example_class 'Spec::CustomError', Cuprum::Error

      describe 'with a failing result' do
        let(:result) { Cuprum::Result.new(status: :failure) }
        let(:response_class) do
          Cuprum::Rails::Responses::Html::RedirectResponse
        end

        it { expect(responder.call(result)).to be_a response_class }
      end

      describe 'with a failing result with an error' do
        let(:error)  { Spec::CustomError.new }
        let(:result) { Cuprum::Result.new(status: :failure, error:) }

        it 'should match the responder' do
          expect(responder.call(result))
            .to be == 'responder: failure with error'
        end
      end

      describe 'with a passing result' do
        let(:result) { Cuprum::Result.new(status: :success) }
        let(:response_class) do
          Cuprum::Rails::Responses::Html::RenderResponse
        end

        it { expect(responder.call(result)).to be_a response_class }
      end
    end

    context 'with multiple matchers' do
      let(:matcher) do
        Cuprum::Matcher.new do
          match(:failure) { 'matcher: failure' }
        end
      end
      let(:constructor_options) { super().merge(matcher:) }

      before(:example) do
        Spec::HtmlResponder.action(:process) do
          match(:failure, error: Spec::CustomError) do
            'action: failure with error'
          end
        end

        Spec::HtmlResponder.match(:failure, error: Spec::CustomError) do
          # :nocov:
          'responder: failure with error'
          # :nocov:
        end
      end

      example_class 'Spec::CustomError', Cuprum::Error

      describe 'with a non-matching action name' do
        describe 'with a failing result' do
          let(:result) { Cuprum::Result.new(status: :failure) }

          it { expect(responder.call(result)).to be == 'matcher: failure' }
        end

        describe 'with a failing result with an error' do
          let(:error)  { Spec::CustomError.new }
          let(:result) { Cuprum::Result.new(status: :failure, error:) }

          it 'should match the responder' do
            expect(responder.call(result))
              .to be == 'responder: failure with error'
          end
        end

        describe 'with a passing result' do
          let(:result) { Cuprum::Result.new(status: :success) }
          let(:response_class) do
            Cuprum::Rails::Responses::Html::RenderResponse
          end

          it { expect(responder.call(result)).to be_a response_class }
        end
      end

      describe 'with a matching action name' do
        let(:action_name) { :process }

        describe 'with a failing result' do
          let(:result) { Cuprum::Result.new(status: :failure) }

          it { expect(responder.call(result)).to be == 'matcher: failure' }
        end

        describe 'with a failing result with an error' do
          let(:error)  { Spec::CustomError.new }
          let(:result) { Cuprum::Result.new(status: :failure, error:) }

          it 'should match the action' do
            expect(responder.call(result))
              .to be == 'action: failure with error'
          end
        end

        describe 'with a passing result' do
          let(:result) { Cuprum::Result.new(status: :success) }
          let(:response_class) do
            Cuprum::Rails::Responses::Html::RenderResponse
          end

          it { expect(responder.call(result)).to be_a response_class }
        end
      end
    end
  end

  describe '#format' do
    include_examples 'should define reader', :format, :html
  end

  describe '#head' do
    let(:status)   { 500 }
    let(:options)  { { status: 500 } }
    let(:response) { responder.head(**options) }
    let(:response_class) do
      Cuprum::Rails::Responses::HeadResponse
    end

    it 'should define the method' do
      expect(responder)
        .to respond_to(:head)
        .with(0).arguments
        .and_keywords(:status)
    end

    it { expect(response).to be_a response_class }

    it { expect(response.status).to be 500 }
  end

  describe '#redirect_back' do
    let(:options)  { {} }
    let(:response) { responder.redirect_back(**options) }
    let(:response_class) do
      Cuprum::Rails::Responses::Html::RedirectBackResponse
    end

    it 'should define the method' do
      expect(responder)
        .to respond_to(:redirect_back)
        .with(0).arguments
        .and_keywords(:fallback_location, :status)
    end

    it { expect(response).to be_a response_class }

    it { expect(response.fallback_location).to be == '/' }

    it { expect(response.status).to be 302 }

    describe 'with fallback_location: value' do
      let(:options) { super().merge(fallback_location: '/path/to/resource') }

      it { expect(response).to be_a response_class }

      it { expect(response.fallback_location).to be == '/path/to/resource' }

      it { expect(response.status).to be 302 }
    end

    describe 'with status: value' do
      let(:options) { super().merge(status: 303) }

      it { expect(response).to be_a response_class }

      it { expect(response.fallback_location).to be == '/' }

      it { expect(response.status).to be 303 }
    end
  end

  describe '#redirect_to' do
    let(:path)     { 'www.example.com' }
    let(:options)  { {} }
    let(:response) { responder.redirect_to(path, **options) }
    let(:response_class) do
      Cuprum::Rails::Responses::Html::RedirectResponse
    end

    it 'should define the method' do
      expect(responder)
        .to respond_to(:redirect_to)
        .with(1).argument
        .and_keywords(:status)
    end

    it { expect(response).to be_a response_class }

    it { expect(response.path).to be == path }

    it { expect(response.status).to be 302 }

    describe 'with status: value' do
      let(:status)  { 308 }
      let(:options) { super().merge(status:) }

      it { expect(response).to be_a response_class }

      it { expect(response.path).to be == path }

      it { expect(response.status).to be status }
    end
  end

  describe '#render' do
    let(:template) { :process }
    let(:options)  { {} }
    let(:result)   { Cuprum::Result.new }
    let(:response) { responder.render(template, **options) }
    let(:response_class) do
      Cuprum::Rails::Responses::Html::RenderResponse
    end

    before(:example) do
      allow(responder) # rubocop:disable RSpec/SubjectStub
        .to receive(:result)
        .and_return(result)
    end

    it 'should define the method' do
      expect(responder)
        .to respond_to(:render)
        .with(1).argument
        .and_keywords(:assigns, :layout, :status)
    end

    it { expect(response).to be_a response_class }

    it { expect(response.layout).to be nil }

    it { expect(response.status).to be 200 }

    it { expect(response.template).to be == template }

    context 'when the result is failing' do
      let(:result) { Cuprum::Result.new(status: :failure) }

      it { expect(response.assigns).to be == {} }

      context 'when the result has an error' do
        let(:error)    { Cuprum::Error.new(message: 'Something went wrong.') }
        let(:result)   { Cuprum::Result.new(status: :failure, error:) }
        let(:expected) { { error: } }

        it { expect(response.assigns).to be == expected }
      end

      context 'when the result has an error and a value' do
        let(:error)    { Cuprum::Error.new(message: 'Something went wrong.') }
        let(:value)    { { ok: false } }
        let(:expected) { value.merge(error:) }
        let(:result) do
          Cuprum::Result.new(status: :failure, error:, value:)
        end

        it { expect(response.assigns).to be == expected }
      end
    end

    context 'when the result is passing' do
      let(:result) { Cuprum::Result.new(status: :success) }

      it { expect(response.assigns).to be == {} }

      context 'when the result has a non-Hash value' do
        let(:result)   { Cuprum::Result.new(status: :success, value: :ok) }
        let(:expected) { { value: :ok } }

        it { expect(response.assigns).to be == expected }
      end

      context 'when the result has a Hash value' do
        let(:value)    { { ok: true } }
        let(:result)   { Cuprum::Result.new(status: :success, value:) }
        let(:expected) { value }

        it { expect(response.assigns).to be == expected }
      end
    end

    describe 'with assigns: value' do
      let(:assigns) { { key: 'value' } }
      let(:options) { super().merge(assigns:) }

      it { expect(response.assigns).to be == assigns }
    end

    describe 'with layout: value' do
      let(:layout)  { 'page' }
      let(:options) { super().merge(layout:) }

      it { expect(response.layout).to be == layout }
    end

    describe 'with status: value' do
      let(:status)  { 201 }
      let(:options) { super().merge(status:) }

      it { expect(response.status).to be status }
    end
  end
end
