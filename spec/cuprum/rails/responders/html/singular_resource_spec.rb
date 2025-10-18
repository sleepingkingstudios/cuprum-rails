# frozen_string_literal: true

require 'cuprum/rails/responders/html/singular_resource'
require 'cuprum/rails/rspec/deferred/responder_examples'
require 'cuprum/rails/rspec/deferred/responses/html_response_examples'

RSpec.describe Cuprum::Rails::Responders::Html::SingularResource do
  include Cuprum::Rails::RSpec::Deferred::ResponderExamples
  include Cuprum::Rails::RSpec::Deferred::Responses::HtmlResponseExamples

  subject(:responder) { described_class.new(**constructor_options) }

  let(:described_class) { Spec::ResourceResponder }
  let(:constructor_options) do
    {
      action_name:,
      controller:,
      request:
    }
  end

  example_class 'Spec::ResourceResponder',
    Cuprum::Rails::Responders::Html::SingularResource # rubocop:disable RSpec/DescribedClass

  before(:example) do
    allow(SleepingKingStudios::Tools::CoreTools).to receive(:deprecate)
  end

  include_deferred 'should implement the Responder methods',
    constructor_keywords: %i[matcher]

  describe '#call' do
    shared_examples 'should redirect to the show page' do
      let(:response_class) do
        Cuprum::Rails::Responses::Html::RedirectResponse
      end

      it { expect(response).to be_a response_class }

      it { expect(response.path).to be == resource.routes.show_path }

      it { expect(response.status).to be 302 }
    end

    shared_examples 'should redirect to the parent resource page' do
      let(:response_class) do
        Cuprum::Rails::Responses::Html::RedirectResponse
      end

      it { expect(response).to be_a response_class }

      it { expect(response.path).to be == resource.routes.parent_path }

      it { expect(response.status).to be 302 }
    end

    shared_examples 'should render the template' do
      let(:response_class) do
        Cuprum::Rails::Responses::Html::RenderResponse
      end

      it { expect(response).to be_a response_class }

      it { expect(response.assigns).to be == value }

      it { expect(response.layout).to be nil }

      it { expect(response.template).to be == action_name }

      it { expect(response.status).to be 200 }
    end

    let(:resource) do
      Cuprum::Rails::Resource.new(
        name:     'book',
        singular: true
      )
    end
    let(:response) { responder.call(result) }

    context 'when initialized with action_name: :create' do
      let(:action_name) { :create }

      describe 'with a failing result' do
        let(:result) { Cuprum::Result.new(status: :failure) }

        include_examples 'should redirect to the show page'
      end

      describe 'with a failing result with a FailedValidation error' do
        let(:entity_class) { Struct.new(:title) }
        let(:errors) do
          errors = Stannum::Errors.new
          errors[:author].add('spec.empty')
          errors
        end
        let(:error) do
          Cuprum::Collections::Errors::FailedValidation.new(
            entity_class:,
            errors:
          )
        end
        let(:value)    { { 'book' => entity_class.new('Gideon the Ninth') } }
        let(:result)   { Cuprum::Result.new(error:, value:) }
        let(:response) { responder.call(result) }
        let(:response_class) do
          Cuprum::Rails::Responses::Html::RenderResponse
        end
        let(:expected) { value.merge('errors' => errors) }

        it { expect(response).to be_a response_class }

        it { expect(response.assigns).to be == expected }

        it { expect(response.layout).to be nil }

        it { expect(response.template).to be == :new }

        it { expect(response.status).to be 422 }
      end

      describe 'with a passing result' do
        let(:entity) { Spec::Model.new(0, 'Gideon the Ninth') }
        let(:value)  { { 'book' => entity } }
        let(:result) { Cuprum::Result.new(value:) }
        let(:response) { responder.call(result) }
        let(:response_class) do
          Cuprum::Rails::Responses::Html::RedirectResponse
        end

        example_class 'Spec::Model', Struct.new(:id, :title) do |klass|
          klass.define_singleton_method(:primary_key) { :id }
        end

        it { expect(response).to be_a response_class }

        it { expect(response.path).to be == resource.routes.show_path }

        it { expect(response.status).to be 302 }
      end
    end

    context 'when initialized with action_name: :destroy' do
      let(:action_name) { :destroy }

      describe 'with a failing result' do
        let(:result) { Cuprum::Result.new(status: :failure) }

        include_deferred 'should redirect back',
          fallback_location: -> { resource.routes.show_path }
      end

      describe 'with a passing result' do
        let(:result) { Cuprum::Result.new(status: :success) }

        include_examples 'should redirect to the parent resource page'
      end
    end

    context 'when initialized with action_name: :edit' do
      let(:action_name) { :edit }

      describe 'with a failing result' do
        let(:result) { Cuprum::Result.new(status: :failure) }

        include_examples 'should redirect to the show page'
      end

      describe 'with a passing result' do
        let(:value) do
          { 'book' => Struct.new(:title).new('Gideon the Ninth') }
        end
        let(:result) { Cuprum::Result.new(value:) }

        example_class 'Spec::Model', Struct.new(:id, :title) do |klass|
          klass.define_singleton_method(:primary_key) { :id }
        end

        include_examples 'should render the template'
      end
    end

    context 'when initialized with action_name: :new' do
      let(:action_name) { :new }

      describe 'with a failing result' do
        let(:result) { Cuprum::Result.new(status: :failure) }

        include_examples 'should redirect to the show page'
      end

      describe 'with a passing result' do
        let(:value) do
          { 'book' => Struct.new(:title).new('Gideon the Ninth') }
        end
        let(:result) { Cuprum::Result.new(value:) }

        include_examples 'should render the template'
      end
    end

    context 'when initialized with action_name: :show' do
      let(:action_name) { :show }

      describe 'with a failing result' do
        let(:result) { Cuprum::Result.new(status: :failure) }

        include_examples 'should redirect to the show page'
      end

      describe 'with a passing result' do
        let(:value) do
          { 'book' => Struct.new(:title).new('Gideon the Ninth') }
        end
        let(:result) { Cuprum::Result.new(value:) }

        include_examples 'should render the template'
      end
    end

    context 'when initialized with action_name: :update' do
      let(:action_name) { :update }

      describe 'with a failing result' do
        let(:result) { Cuprum::Result.new(status: :failure) }

        include_examples 'should redirect to the show page'
      end

      describe 'with a failing result with a FailedValidation error' do
        let(:entity_class) { Struct.new(:title) }
        let(:errors) do
          errors = Stannum::Errors.new
          errors[:author].add('spec.empty')
          errors
        end
        let(:error) do
          Cuprum::Collections::Errors::FailedValidation.new(
            entity_class:,
            errors:
          )
        end
        let(:value)    { { 'book' => entity_class.new('Gideon the Ninth') } }
        let(:result)   { Cuprum::Result.new(error:, value:) }
        let(:response) { responder.call(result) }
        let(:response_class) do
          Cuprum::Rails::Responses::Html::RenderResponse
        end
        let(:expected) { value.merge('errors' => errors) }

        it { expect(response).to be_a response_class }

        it { expect(response.assigns).to be == expected }

        it { expect(response.layout).to be nil }

        it { expect(response.template).to be == :edit }

        it { expect(response.status).to be 422 }
      end

      describe 'with a passing result' do
        let(:entity) { Spec::Model.new(0, 'Gideon the Ninth') }
        let(:value)  { { 'book' => entity } }
        let(:result) { Cuprum::Result.new(value:) }
        let(:response) { responder.call(result) }
        let(:response_class) do
          Cuprum::Rails::Responses::Html::RedirectResponse
        end

        example_class 'Spec::Model', Struct.new(:id, :title) do |klass|
          klass.define_singleton_method(:primary_key) { :id }
        end

        it { expect(response).to be_a response_class }

        it { expect(response.path).to be == resource.routes.show_path }

        it { expect(response.status).to be 302 }
      end
    end

    context 'when initialized with action_name: another action' do
      let(:action_name) { :publish }

      describe 'with a failing result' do
        let(:result) { Cuprum::Result.new(status: :failure) }

        include_examples 'should redirect to the show page'
      end

      describe 'with a passing result' do
        let(:value) do
          { 'book' => Struct.new(:title).new('Gideon the Ninth') }
        end
        let(:result) { Cuprum::Result.new(value:) }

        include_examples 'should render the template'
      end
    end
  end
end
