# frozen_string_literal: true

require 'cuprum/rails/responders/html/resource'
require 'cuprum/rails/rspec/deferred/responder_examples'

RSpec.describe Cuprum::Rails::Responders::Html::Resource do
  include Cuprum::Rails::RSpec::Deferred::ResponderExamples

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
    Cuprum::Rails::Responders::Html::Resource # rubocop:disable RSpec/DescribedClass

  include_deferred 'should implement the Responder methods',
    constructor_keywords: %i[matcher]

  describe '#call' do
    shared_examples 'should handle a NotFound error' do
      describe 'with a failing result with a NotFound error' do
        let(:result)   { Cuprum::Result.new(error:) }
        let(:response) { responder.call(result) }

        context 'when the error does not match a resource' do
          let(:error) do
            Cuprum::Collections::Errors::NotFound.new(
              attribute_name:  'id',
              attribute_value: 1,
              collection_name: 'series',
              primary_key:     true
            )
          end

          include_deferred 'should render template',
            -> { action_name },
            assigns: -> { { 'error' => error } },
            status:  404
        end

        context 'when the error matches the resource' do
          let(:error) do
            Cuprum::Collections::Errors::NotFound.new(
              attribute_name:  'id',
              attribute_value: 0,
              collection_name: 'books',
              primary_key:     true
            )
          end
          let(:expected_path) do
            if resource.singular?
              resource.routes.show_path
            else
              resource.routes.index_path
            end
          end

          include_deferred 'should redirect to', -> { expected_path }
        end

        context 'when the resource has ancestors' do
          let(:authors_resource) do
            Cuprum::Rails::Resource.new(name: 'authors')
          end
          let(:series_resource) do
            Cuprum::Rails::Resource.new(
              name:          'series',
              singular_name: 'series',
              parent:        authors_resource
            )
          end
          let(:resource_options) { super().merge(parent: series_resource) }
          let(:path_params) do
            {
              'author_id' => 0,
              'series_id' => 1,
              'id'        => 2
            }
          end
          let(:request) do
            Cuprum::Rails::Request.new(
              action_name:,
              path_params:
            )
          end

          context 'when the error does not match a resource' do
            let(:error) do
              Cuprum::Collections::Errors::NotFound.new(
                attribute_name:  'borrower_id',
                attribute_value: 3,
                collection_name: 'borrowers',
                primary_key:     true
              )
            end

            include_deferred 'should render template',
              -> { action_name },
              assigns: -> { { 'error' => error } },
              status:  404
          end

          context 'when the error matches the primary resource' do
            let(:error) do
              Cuprum::Collections::Errors::NotFound.new(
                attribute_name:  'id',
                attribute_value: 2,
                collection_name: 'books',
                primary_key:     true
              )
            end
            let(:expected_path) do
              routes = resource.routes.with_wildcards(request.path_params)

              if resource.singular?
                routes.show_path
              else
                routes.index_path
              end
            end

            include_deferred 'should redirect to', -> { expected_path }
          end

          context 'when the error matches the parent resource' do
            let(:error) do
              Cuprum::Collections::Errors::NotFound.new(
                attribute_name:  'id',
                attribute_value: 1,
                collection_name: 'series',
                primary_key:     true
              )
            end
            let(:expected_path) do
              series_resource
                .routes
                .with_wildcards(request.path_params)
                .index_path
            end

            include_deferred 'should redirect to', -> { expected_path }
          end

          context 'when the error matches the top-level resource' do
            let(:error) do
              Cuprum::Collections::Errors::NotFound.new(
                attribute_name:  'id',
                attribute_value: 0,
                collection_name: 'authors',
                primary_key:     true
              )
            end
            let(:expected_path) do
              authors_resource
                .routes
                .with_wildcards(request.path_params)
                .index_path
            end

            include_deferred 'should redirect to', -> { expected_path }
          end
        end
      end
    end

    shared_examples 'should redirect to the index page' do
      let(:response) { responder.call(result) }

      include_deferred 'should redirect to', -> { resource.routes.index_path }

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

    shared_examples 'should redirect to the show page' do
      let(:response) { responder.call(result) }

      include_deferred 'should redirect to', -> { resource.routes.show_path }

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
          resource.routes.with_wildcards(path_params).show_path
        end

        include_deferred 'should redirect to', -> { expected_path }
      end
    end

    shared_examples 'should redirect to the parent resource page' do
      let(:response) { responder.call(result) }

      include_deferred 'should redirect to', -> { resource.routes.parent_path }

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
          resource.routes.with_wildcards(path_params).parent_path
        end

        include_deferred 'should redirect to', -> { expected_path }
      end
    end

    shared_examples 'should render the template' do
      let(:response) { responder.call(result) }

      include_deferred 'should render template',
        -> { action_name },
        assigns: -> { value }
    end

    context 'when initialized with a plural resource' do
      context 'when initialized with action_name: :create' do
        let(:action_name) { :create }

        include_examples 'should handle a NotFound error'

        describe 'with a failing result' do
          let(:result) { Cuprum::Result.new(status: :failure) }

          include_examples 'should redirect to the index page'
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
          let(:value)  { { 'book' => entity_class.new('Gideon the Ninth') } }
          let(:result) { Cuprum::Result.new(error:, value:) }

          include_deferred 'should render template',
            'new',
            assigns: -> { value.merge('errors' => errors) },
            status:  422
        end

        describe 'with a passing result' do
          let(:entity) { Spec::Model.new(0, 'Gideon the Ninth') }
          let(:value)  { { 'book' => entity } }
          let(:result) { Cuprum::Result.new(value:) }

          example_class 'Spec::Model', Struct.new(:id, :title) do |klass|
            klass.define_singleton_method(:primary_key) { :id }
          end

          include_deferred 'should redirect to',
            -> { resource.routes.show_path(entity) }
        end
      end

      context 'when initialized with action_name: :destroy' do
        let(:action_name) { :destroy }

        include_examples 'should handle a NotFound error'

        describe 'with a failing result' do
          let(:result) { Cuprum::Result.new(status: :failure) }

          include_deferred 'should redirect back',
            fallback_location: -> { resource.routes.index_path }
        end

        describe 'with a passing result' do
          let(:result) { Cuprum::Result.new(status: :success) }

          include_examples 'should redirect to the index page'
        end
      end

      context 'when initialized with action_name: :edit' do
        let(:action_name) { :edit }

        include_examples 'should handle a NotFound error'

        describe 'with a failing result' do
          let(:result) { Cuprum::Result.new(status: :failure) }

          include_examples 'should redirect to the index page'
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

      context 'when initialized with action_name: :index' do
        let(:action_name) { :index }

        include_examples 'should handle a NotFound error'

        describe 'with a failing result' do
          let(:result) { Cuprum::Result.new(status: :failure) }

          include_deferred 'should redirect to',
            -> { resource.routes.root_path }
        end

        describe 'with a passing result' do
          let(:value) do
            { 'books' => [Struct.new(:title).new('Gideon the Ninth')] }
          end
          let(:result) { Cuprum::Result.new(value:) }

          include_examples 'should render the template'
        end
      end

      context 'when initialized with action_name: :new' do
        let(:action_name) { :new }

        include_examples 'should handle a NotFound error'

        describe 'with a failing result' do
          let(:result) { Cuprum::Result.new(status: :failure) }

          include_examples 'should redirect to the index page'
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

        include_examples 'should handle a NotFound error'

        describe 'with a failing result' do
          let(:result) { Cuprum::Result.new(status: :failure) }

          include_examples 'should redirect to the index page'
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

        include_examples 'should handle a NotFound error'

        describe 'with a failing result' do
          let(:result) { Cuprum::Result.new(status: :failure) }

          include_examples 'should redirect to the index page'
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
          let(:value)  { { 'book' => entity_class.new('Gideon the Ninth') } }
          let(:result) { Cuprum::Result.new(error:, value:) }

          include_deferred 'should render template',
            'edit',
            assigns: -> { value.merge('errors' => errors) },
            status:  422
        end

        describe 'with a passing result' do
          let(:entity) { Spec::Model.new(0, 'Gideon the Ninth') }
          let(:value)  { { 'book' => entity } }
          let(:result) { Cuprum::Result.new(value:) }

          example_class 'Spec::Model', Struct.new(:id, :title) do |klass|
            klass.define_singleton_method(:primary_key) { :id }
          end

          include_deferred 'should redirect to',
            -> { resource.routes.show_path(entity) }
        end
      end

      context 'when initialized with action_name: another action' do
        let(:action_name) { :publish }

        include_examples 'should handle a NotFound error'

        describe 'with a failing result' do
          let(:result) { Cuprum::Result.new(status: :failure) }

          include_examples 'should redirect to the index page'
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

    context 'when initialized with a singular resource' do
      let(:resource_options) { super().merge(singular: true) }

      context 'when initialized with action_name: :create' do
        let(:action_name) { :create }

        include_examples 'should handle a NotFound error'

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
          let(:value)  { { 'book' => entity_class.new('Gideon the Ninth') } }
          let(:result) { Cuprum::Result.new(error:, value:) }

          include_deferred 'should render template',
            'new',
            assigns: -> { value.merge('errors' => errors) },
            status:  422
        end

        describe 'with a passing result' do
          let(:entity) { Spec::Model.new(0, 'Gideon the Ninth') }
          let(:value)  { { 'book' => entity } }
          let(:result) { Cuprum::Result.new(value:) }
          let(:response) { responder.call(result) }

          example_class 'Spec::Model', Struct.new(:id, :title) do |klass|
            klass.define_singleton_method(:primary_key) { :id }
          end

          include_deferred 'should redirect to',
            -> { resource.routes.show_path }
        end
      end

      context 'when initialized with action_name: :destroy' do
        let(:action_name) { :destroy }

        include_examples 'should handle a NotFound error'

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

        include_examples 'should handle a NotFound error'

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

        include_examples 'should handle a NotFound error'

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

        include_examples 'should handle a NotFound error'

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

        include_examples 'should handle a NotFound error'

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
          let(:value)  { { 'book' => entity_class.new('Gideon the Ninth') } }
          let(:result) { Cuprum::Result.new(error:, value:) }

          include_deferred 'should render template',
            'edit',
            assigns: -> { value.merge('errors' => errors) },
            status:  422
        end

        describe 'with a passing result' do
          let(:entity) { Spec::Model.new(0, 'Gideon the Ninth') }
          let(:value)  { { 'book' => entity } }
          let(:result) { Cuprum::Result.new(value:) }

          example_class 'Spec::Model', Struct.new(:id, :title) do |klass|
            klass.define_singleton_method(:primary_key) { :id }
          end

          include_deferred 'should redirect to',
            -> { resource.routes.show_path }
        end
      end

      context 'when initialized with action_name: another action' do
        let(:action_name) { :publish }

        include_examples 'should handle a NotFound error'

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
end
