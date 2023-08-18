# frozen_string_literal: true

require 'cuprum/collections/rspec/fixtures'

require 'support/controllers/books_controller'

# @note Integration spec for Cuprum::Rails::Controller.
RSpec.describe BooksController do
  subject(:controller) do
    described_class.new(
      renderer: renderer,
      request:  request
    )
  end

  shared_context 'when there are many books' do
    before(:example) do
      Cuprum::Collections::RSpec::BOOKS_FIXTURES.each do |attributes|
        Book.create!(attributes.except(:id))
      end
    end
  end

  shared_context 'with format: :html' do
    let(:format) { :html }
  end

  shared_context 'with format: :json' do
    let(:format) { :json }
    let(:path)   { "#{super()}.json" }
  end

  shared_examples 'should redirect to the index page' do
    it 'should redirect to the index page' do
      controller.send(action_name)

      expect(renderer)
        .to have_received(:redirect_to)
        .with('/books', { status: 302 })
    end
  end

  shared_examples 'should redirect to the show page' do
    it 'should redirect to the show page' do
      controller.send(action_name)

      expect(renderer)
        .to have_received(:redirect_to)
        .with("/books/#{expected_book.id}", { status: 302 })
    end
  end

  shared_examples 'should render the view' do |expected_view|
    include_context 'with format: :html'

    let(:status) { defined?(super()) ? super() : 200 }

    it 'should render the view' do
      controller.send(action_name)

      expect(renderer)
        .to have_received(:render)
        .with((expected_view || action_name), { status: status })
    end

    it 'should assign the queried data' do
      controller.send(action_name)

      expect(assigns).to deep_match(expected_assigns)
    end
  end

  shared_examples 'should serialize the data' do
    include_context 'with format: :json'

    let(:status) { defined?(super()) ? super() : 200 }
    let(:expected_json) do
      {
        'ok'   => true,
        'data' => expected_data
      }
    end

    it 'should render the json' do
      controller.send(action_name)

      expect(renderer)
        .to have_received(:render)
        .with(json: expected_json, status: status)
    end
  end

  shared_examples 'should serialize the error' do
    include_context 'with format: :json'

    let(:expected_json) do
      {
        'ok'    => false,
        'error' => expected_error.as_json
      }
    end
    let(:status) { defined?(super()) ? super() : 400 }

    it 'should render the json' do
      controller.send(action_name)

      expect(renderer)
        .to have_received(:render)
        .with(json: expected_json, status: status)
    end
  end

  shared_examples 'should require a book parameter' do
    describe 'with a missing book parameter' do
      let(:params) { super().tap { |hsh| hsh.delete('book') } }
      let(:expected_error) do
        errors = Stannum::Errors.new.tap do |err|
          err['book'].add(Stannum::Constraints::Presence::TYPE)
        end

        Cuprum::Rails::Errors::InvalidParameters
          .new(errors: errors)
          .as_json
      end

      wrap_examples 'should redirect to the index page'

      wrap_examples 'should serialize the error'
    end

    describe 'with an empty book parameter' do
      let(:params) { super().merge('book' => {}) }
      let(:expected_error) do
        errors = Stannum::Errors.new.tap do |err|
          err['book'].add(Stannum::Constraints::Presence::TYPE)
        end

        Cuprum::Rails::Errors::InvalidParameters
          .new(errors: errors)
          .as_json
      end

      wrap_examples 'should redirect to the index page'

      wrap_examples 'should serialize the error'
    end
  end

  shared_examples 'should require a valid book id' do |api: true|
    describe 'with a missing book id' do
      let(:path_params) { super().tap { |hsh| hsh.delete('id') } }
      let(:expected_error) do
        errors = Stannum::Errors.new.tap do |err|
          err['id'].add(Stannum::Constraints::Presence::TYPE)
        end

        Cuprum::Rails::Errors::InvalidParameters
          .new(errors: errors)
          .as_json
      end
      let(:status) { 400 }

      wrap_examples 'should redirect to the index page'

      wrap_examples 'should serialize the error' if api
    end

    describe 'with an invalid book id' do
      let(:book_id)     { (Book.last&.id || -1) + 1 }
      let(:path_params) { super().merge('id' => book_id) }
      let(:expected_error) do
        Cuprum::Collections::Errors::NotFound.new(
          attribute_name:  'id',
          attribute_value: book_id,
          collection_name: 'books',
          primary_key:     true
        )
      end
      let(:status) { 404 }

      wrap_examples 'should redirect to the index page'

      wrap_examples 'should serialize the error' if api
    end
  end

  shared_examples 'should log the action' do
    before(:example) { Spec::Support::Middleware::LoggingMiddleware.clear_logs }

    it 'should log the action' do
      controller.send(action_name)

      expect(Spec::Support::Middleware::LoggingMiddleware.logs.string)
        .to be == expected_logs
    end
  end

  let(:action_name)  { nil }
  let(:assigns)      { controller.assigns }
  let(:format)       { :html }
  let(:headers)      { {} }
  let(:params)       { {} }
  let(:query_params) { {} }
  let(:path_params)  { {} }
  let(:renderer) do
    instance_double(Spec::Renderer, redirect_to: nil, render: nil)
  end
  let(:request) do
    combined_params =
      query_params
        .merge(params)
        .merge('action' => action_name, 'controller' => 'books')

    instance_double(
      ActionDispatch::Request,
      authorization:         nil,
      format:                instance_double(Mime::Type, symbol: format),
      fullpath:              path,
      headers:               headers,
      params:                combined_params,
      path_parameters:       path_params,
      query_parameters:      query_params,
      request_method_symbol: method,
      request_parameters:    params
    )
  end
  let(:context) do
    Cuprum::Rails::Serializers::Context.new(
      serializers: Cuprum::Rails::Serializers::Json.default_serializers
    )
  end
  let(:serializer) do
    Spec::Support::Serializers::BookSerializer.new
  end

  example_class 'Spec::Renderer' do |klass|
    klass.define_method(:redirect_to) { |*_, **_| nil }
    klass.define_method(:render)      { |*_, **_| nil }
  end

  before(:example) do
    current_time = Time.current

    allow(Time)
      .to receive(:current)
      .and_return(current_time, current_time + 0.05)
  end

  describe '#create' do
    let(:action_name) { :create }
    let(:method)      { :post }
    let(:path)        { '/books' }
    let(:attributes)  { { title: 'Gideon the Ninth' } }
    let(:params)      { { 'book' => attributes } }

    it { expect(controller).to respond_to(:create).with(0).arguments }

    include_examples 'should require a book parameter'

    describe 'with invalid attributes' do
      let(:attributes)    { { 'title' => 'Gideon the Ninth' } }
      let(:expected_book) { Book.new(attributes) }
      let(:expected_errors) do
        native_errors = expected_book.tap(&:valid?).errors
        raw_errors    =
          Cuprum::Rails::MapErrors.instance.call(native_errors: native_errors)
        mapped_errors = Stannum::Errors.new

        raw_errors.each do |err|
          mapped_errors
            .dig('book', *err[:path].map(&:to_s))
            .add(err[:type], message: err[:message], **err[:data])
        end

        mapped_errors
      end
      let(:expected_error) do
        Cuprum::Collections::Errors::FailedValidation
          .new(entity_class: Book, errors: expected_errors)
          .as_json
      end
      let(:expected_assigns) do
        {
          '@book'   => expected_book,
          '@errors' => expected_errors
        }
      end
      let(:expected_logs) do
        <<~RAW
          [ERROR] Action failure: books#create (Book failed validation)
          - repository_keys: books
          - resource_name: books
        RAW
      end
      let(:status) { 422 }

      it 'should not create a book' do
        expect { controller.create }.not_to change(Book, :count)
      end

      wrap_examples 'should render the view', :new

      wrap_examples 'should serialize the error'

      wrap_examples 'should log the action'
    end

    describe 'with valid attributes' do
      let(:attributes) do
        {
          'title'  => 'Gideon the Ninth',
          'author' => 'Tamsyn Muir'
        }
      end
      let(:params) { super().merge(book: attributes) }
      let(:expected_book) do
        Book.where(attributes).first
      end
      let(:expected_data) do
        {
          'book'         => expected_book.as_json,
          'time_elapsed' => '50 milliseconds'
        }
      end
      let(:expected_logs) do
        <<~RAW
          [INFO] Action success: books#create
          - repository_keys: books
          - resource_name: books
        RAW
      end
      let(:status) { 201 }

      it 'should create a book' do
        expect { controller.create }.to change(Book, :count).by(1)
      end

      wrap_examples 'should redirect to the show page'

      wrap_examples 'should serialize the data'

      wrap_examples 'should log the action'
    end
  end

  describe '#destroy' do
    let(:action_name)  { :destroy }
    let(:method)       { :delete }
    let(:path)         { "/books/#{book_id}" }
    let(:book_id)      { (Book.last&.id || -1) + 1 }
    let(:path_params)  { super().merge('id' => book_id) }

    it { expect(controller).to respond_to(:destroy).with(0).arguments }

    include_examples 'should require a valid book id'

    wrap_context 'when there are many books' do
      let(:book)    { Book.where(title: 'The Tombs of Atuan').first }
      let(:book_id) { book.id }
      let(:expected_data) do
        {
          'book'         => serializer.call(book, context: context),
          'time_elapsed' => '50 milliseconds'
        }
      end
      let(:expected_logs) do
        <<~RAW
          [INFO] Action success: books#destroy
          - repository_keys: books
          - resource_name: books
        RAW
      end

      it 'should destroy the book' do
        expect { controller.destroy }.to change(Book, :count).by(-1)
      end

      it 'should remove the book from the collection' do
        controller.destroy

        expect(Book.exists?(title: 'The Tombs of Atuan')).to be false
      end

      wrap_examples 'should redirect to the index page'

      wrap_examples 'should serialize the data'

      wrap_examples 'should log the action'
    end
  end

  describe '#edit' do
    let(:action_name)  { :edit }
    let(:method)       { :get }
    let(:path)         { "books/#{book_id}/edit" }
    let(:book_id)      { (Book.last&.id || -1) + 1 }
    let(:path_params)  { super().merge('id' => book_id) }

    it { expect(controller).to respond_to(:edit).with(0).arguments }

    include_examples 'should require a valid book id', api: false

    wrap_context 'when there are many books' do
      let(:book)    { Book.where(title: 'The Tombs of Atuan').first }
      let(:book_id) { book.id }
      let(:expected_assigns) do
        {
          '@book'         => book,
          '@time_elapsed' => '50 milliseconds'
        }
      end

      wrap_examples 'should render the view'
    end
  end

  describe '#index' do
    let(:action_name)    { :index }
    let(:method)         { :get }
    let(:path)           { '/books' }
    let(:expected_books) { [] }
    let(:expected_assigns) do
      {
        '@books'        => expected_books.to_a,
        '@time_elapsed' => '50 milliseconds'
      }
    end
    let(:expected_data) do
      {
        'books'        => expected_books.map do |book|
          serializer.call(book, context: context)
        end,
        'time_elapsed' => '50 milliseconds'
      }
    end

    it { expect(controller).to respond_to(:index).with(0).arguments }

    wrap_examples 'should render the view'

    wrap_examples 'should serialize the data'

    wrap_context 'when there are many books' do
      let(:expected_books) { Book.order(:id).to_a }

      wrap_examples 'should render the view'

      wrap_examples 'should serialize the data'

      context 'with filter params' do
        let(:params) do
          super().merge(
            order: :title,
            where: { 'author' => 'Ursula K. LeGuin' }
          )
        end
        let(:expected_books) do
          Book.where(author: 'Ursula K. LeGuin').order(:title).to_a
        end

        wrap_examples 'should render the view'

        wrap_examples 'should serialize the data'
      end
    end
  end

  describe '#new' do
    let(:action_name) { :new }
    let(:method)      { :get }
    let(:path)        { '/books/new' }
    let(:expected_assigns) do
      {
        '@book'         => Book.new,
        '@time_elapsed' => '50 milliseconds'
      }
    end

    it { expect(controller).to respond_to(:new).with(0).arguments }

    wrap_examples 'should render the view'
  end

  describe '#show' do
    let(:action_name)  { :show }
    let(:method)       { :get }
    let(:path)         { "books/#{book_id}" }
    let(:book_id)      { (Book.last&.id || -1) + 1 }
    let(:path_params)  { super().merge('id' => book_id) }

    it { expect(controller).to respond_to(:show).with(0).arguments }

    include_examples 'should require a valid book id'

    wrap_context 'when there are many books' do
      let(:book)    { Book.where(title: 'The Tombs of Atuan').first }
      let(:book_id) { book.id }
      let(:expected_assigns) do
        {
          '@book'         => book,
          '@time_elapsed' => '50 milliseconds'
        }
      end
      let(:expected_data) do
        {
          'book'         => serializer.call(book, context: context),
          'time_elapsed' => '50 milliseconds'
        }
      end

      wrap_examples 'should render the view'

      wrap_examples 'should serialize the data'
    end
  end

  describe '#update' do
    let(:action_name)  { :update }
    let(:method)       { :patch }
    let(:path)         { "books/#{book_id}" }
    let(:book_id)      { (Book.last&.id || -1) + 1 }
    let(:attributes)   { { 'title' => 'Gideon the Ninth' } }
    let(:path_params)  { super().merge('id' => book_id) }
    let(:params)       { super().merge('book' => attributes) }

    it { expect(controller).to respond_to(:update).with(0).arguments }

    include_examples 'should require a valid book id'

    wrap_context 'when there are many books' do
      let(:book)    { Book.where(title: 'The Tombs of Atuan').first }
      let(:book_id) { book.id }

      describe 'with invalid attributes' do
        let(:attributes) { { 'title' => '' } }
        let(:params)     { super().merge(book: attributes) }
        let(:expected_book) do
          book.tap { book.assign_attributes(attributes) }
        end
        let(:expected_errors) do
          native_errors = expected_book.tap(&:valid?).errors
          raw_errors    =
            Cuprum::Rails::MapErrors.instance.call(native_errors: native_errors)
          mapped_errors = Stannum::Errors.new

          raw_errors.each do |err|
            mapped_errors
              .dig('book', *err[:path].map(&:to_s))
              .add(err[:type], message: err[:message], **err[:data])
          end

          mapped_errors
        end
        let(:expected_assigns) do
          {
            '@book'   => expected_book,
            '@errors' => expected_errors
          }
        end
        let(:expected_error) do
          Cuprum::Collections::Errors::FailedValidation.new(
            entity_class: Book,
            errors:       expected_errors
          )
        end
        let(:expected_logs) do
          <<~RAW
            [ERROR] Action failure: books#update (Book failed validation)
            - repository_keys: books
            - resource_name: books
          RAW
        end
        let(:status) { 422 }

        it 'should not update the attributes' do
          expect { controller.update }
            .not_to(change { book.reload.attributes })
        end

        wrap_examples 'should render the view', :edit

        wrap_examples 'should serialize the error'

        wrap_examples 'should log the action'
      end

      describe 'with valid attributes' do
        let(:attributes)    { { 'category' => 'Coming of Age' } }
        let(:params)        { super().merge(book: attributes) }
        let(:expected_book) { book }
        let(:expected_data) do
          {
            'book'         => serializer.call(book.reload, context: context),
            'time_elapsed' => '50 milliseconds'
          }
        end
        let(:expected_logs) do
          <<~RAW
            [INFO] Action success: books#update
            - repository_keys: books
            - resource_name: books
          RAW
        end

        it 'should update the attributes' do
          expect { controller.update }
            .to change { book.reload.attributes }
            .to be >= attributes.stringify_keys
        end

        wrap_examples 'should redirect to the show page'

        wrap_examples 'should serialize the data'

        wrap_examples 'should log the action'
      end
    end
  end
end
