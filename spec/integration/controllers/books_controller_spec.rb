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
    let(:books) { Book.order(:id).to_a }

    before(:example) do
      Cuprum::Collections::RSpec::BOOKS_FIXTURES.each do |attributes|
        Book.create!(attributes.except(:id))
      end
    end
  end

  let(:assigns)      { controller.assigns }
  let(:format)       { :html }
  let(:headers)      { {} }
  let(:params)       { {} }
  let(:query_params) { {} }
  let(:renderer) do
    instance_double(Spec::Renderer, redirect_to: nil, render: nil)
  end
  let(:request) do
    instance_double(
      ActionDispatch::Request,
      authorization:         nil,
      format:                instance_double(Mime::Type, symbol: format),
      fullpath:              path,
      headers:               headers,
      params:                query_params.merge(params),
      query_parameters:      query_params,
      request_method_symbol: method,
      request_parameters:    params
    )
  end

  example_class 'Spec::Renderer' do |klass|
    klass.define_method(:redirect_to) { |*_, **_| nil }
    klass.define_method(:render)      { |*_, **_| nil }
  end

  # rubocop:disable RSpec/NestedGroups
  describe '#create' do
    let(:method) { :post }
    let(:path)   { '/books' }

    it { expect(controller).to respond_to(:create).with(0).arguments }

    describe 'with format: :html' do
      it 'should redirect to the resource root' do
        controller.create

        expect(renderer)
          .to have_received(:redirect_to)
          .with('/books', { status: 302 })
      end

      describe 'with invalid attributes' do
        let(:attributes)    { { title: 'Gideon the Ninth' } }
        let(:params)        { super().merge(book: attributes) }
        let(:expected_book) { Book.new(attributes) }
        let(:expected_errors) do
          native_errors = expected_book.tap(&:valid?).errors

          Cuprum::Rails::MapErrors.instance.call(native_errors: native_errors)
        end
        let(:expected_assigns) do
          {
            '@book'   => expected_book,
            '@errors' => expected_errors
          }
        end

        it 'should render the #new view' do
          controller.create

          expect(renderer)
            .to have_received(:render)
            .with(:new, { status: 422 })
        end

        it 'should assign a new book with the given attributes' do
          controller.create

          expect(assigns).to deep_match(expected_assigns)
        end

        it 'should not create a book' do
          expect { controller.create }.not_to change(Book, :count)
        end
      end

      describe 'with valid attributes' do
        let(:attributes) do
          {
            title:  'Gideon the Ninth',
            author: 'Tamsyn Muir'
          }
        end
        let(:params) { super().merge(book: attributes) }
        let(:created_book) do
          Book.where(attributes).first
        end

        it 'should redirect to the show path' do
          controller.create

          expect(renderer)
            .to have_received(:redirect_to)
            .with("/books/#{created_book.id}", { status: 302 })
        end

        it 'should create a book' do
          expect { controller.create }.to change(Book, :count).by(1)
        end
      end
    end

    describe 'with format: :json' do
      let(:format) { :json }
      let(:path)   { '/books.json' }
      let(:error) do
        Cuprum::Rails::Errors::MissingParameters
          .new(resource_name: 'book')
          .as_json
      end
      let(:expected) do
        {
          'ok'    => false,
          'error' => error
        }
      end

      it 'should render the json' do
        controller.create

        expect(renderer)
          .to have_received(:render)
          .with(json: expected, status: 400)
      end

      describe 'with invalid attributes' do
        let(:attributes)    { { title: 'Gideon the Ninth' } }
        let(:params)        { super().merge(book: attributes) }
        let(:expected_book) { Book.new(attributes) }
        let(:expected_errors) do
          native_errors = expected_book.tap(&:valid?).errors

          Cuprum::Rails::MapErrors.instance.call(native_errors: native_errors)
        end
        let(:error) do
          Cuprum::Collections::Errors::FailedValidation
            .new(entity_class: Book, errors: expected_errors)
            .as_json
        end
        let(:expected) do
          {
            'ok'    => false,
            'error' => error
          }
        end

        it 'should render the json' do
          controller.create

          expect(renderer)
            .to have_received(:render)
            .with(json: expected, status: 422)
        end

        it 'should not create a book' do
          expect { controller.create }.not_to change(Book, :count)
        end
      end

      describe 'with valid attributes' do
        let(:attributes) do
          {
            title:  'Gideon the Ninth',
            author: 'Tamsyn Muir'
          }
        end
        let(:params) { super().merge(book: attributes) }
        let(:created_book) do
          Book.where(attributes).first
        end
        let(:expected) do
          {
            'ok'   => true,
            'data' => { 'book' => created_book.as_json }
          }
        end

        it 'should render the json' do
          controller.create

          expect(renderer)
            .to have_received(:render)
            .with(json: expected, status: 201)
        end

        it 'should create a book' do
          expect { controller.create }.to change(Book, :count).by(1)
        end
      end
    end
  end

  describe '#destroy' do
    let(:method) { :delete }
    let(:path)   { '/books/' }

    it { expect(controller).to respond_to(:destroy).with(0).arguments }

    describe 'with format: :html' do
      it 'should redirect to the resource root' do
        controller.destroy

        expect(renderer)
          .to have_received(:redirect_to)
          .with('/books', { status: 302 })
      end

      describe 'with an invalid resource id' do
        let(:book_id)      { (Book.last&.id || -1) + 1 }
        let(:path)         { "/books/#{book_id}" }
        let(:query_params) { { 'id' => book_id } }

        it 'should redirect to the resource root' do
          controller.destroy

          expect(renderer)
            .to have_received(:redirect_to)
            .with('/books', { status: 302 })
        end
      end

      wrap_context 'when there are many books' do
        describe 'with an invalid resource id' do
          let(:book_id)      { (Book.last&.id || -1) + 1 }
          let(:path)         { "/books/#{book_id}" }
          let(:query_params) { { 'id' => book_id } }

          it 'should redirect to the resource root' do
            controller.destroy

            expect(renderer)
              .to have_received(:redirect_to)
              .with('/books', { status: 302 })
          end

          it 'should not destroy a book' do
            expect { controller.destroy }.not_to change(Book, :count)
          end
        end

        describe 'with a valid resource id' do
          let(:book)         { Book.where(title: 'The Tombs of Atuan').first }
          let(:book_id)      { book.id }
          let(:path)         { "/books/#{book_id}" }
          let(:query_params) { { 'id' => book_id } }

          it 'should redirect to the resource root' do
            controller.destroy

            expect(renderer)
              .to have_received(:redirect_to)
              .with('/books', { status: 302 })
          end

          it 'should destroy the book' do
            expect { controller.destroy }.to change(Book, :count).by(-1)
          end

          it 'should remove the book from the collection' do
            controller.destroy

            expect(Book.exists?(title: 'The Tombs of Atuan')).to be false
          end
        end
      end
    end

    describe 'with format: json' do
      let(:format) { :json }
      let(:path)   { '/books.json' }
      let(:error) do
        Cuprum::Error.new(
          message: 'Something went wrong when processing the request'
        )
      end
      let(:expected) do
        {
          'ok'    => false,
          'error' => error.as_json
        }
      end

      it 'should render the json' do
        controller.destroy

        expect(renderer)
          .to have_received(:render)
          .with(json: expected, status: 500)
      end

      describe 'with an invalid resource id' do
        let(:book_id)      { (Book.last&.id || -1) + 1 }
        let(:path)         { "/books/#{book_id}.json" }
        let(:query_params) { { 'id' => book_id } }
        let(:error) do
          Cuprum::Collections::Errors::NotFound.new(
            collection_name:    'books',
            primary_key_name:   :id,
            primary_key_values: [book_id]
          )
        end

        it 'should render the json' do
          controller.destroy

          expect(renderer)
            .to have_received(:render)
            .with(json: expected, status: 404)
        end
      end

      wrap_context 'when there are many books' do
        describe 'with an invalid resource id' do
          let(:book_id)      { (Book.last&.id || -1) + 1 }
          let(:path)         { "/books/#{book_id}" }
          let(:query_params) { { 'id' => book_id } }
          let(:error) do
            Cuprum::Collections::Errors::NotFound.new(
              collection_name:    'books',
              primary_key_name:   :id,
              primary_key_values: [book_id]
            )
          end

          it 'should render the json' do
            controller.destroy

            expect(renderer)
              .to have_received(:render)
              .with(json: expected, status: 404)
          end

          it 'should not destroy a book' do
            expect { controller.destroy }.not_to change(Book, :count)
          end
        end

        describe 'with a valid resource id' do
          let(:book)         { Book.where(title: 'The Tombs of Atuan').first }
          let(:book_id)      { book.id }
          let(:path)         { "/books/#{book_id}" }
          let(:query_params) { { 'id' => book_id } }
          let(:expected) do
            {
              'ok'   => true,
              'data' => { 'book' => book.as_json }
            }
          end

          it 'should render the json' do
            controller.destroy

            expect(renderer)
              .to have_received(:render)
              .with(json: expected, status: 200)
          end

          it 'should destroy the book' do
            expect { controller.destroy }.to change(Book, :count).by(-1)
          end

          it 'should remove the book from the collection' do
            controller.destroy

            expect(Book.exists?(title: 'The Tombs of Atuan')).to be false
          end
        end
      end
    end
  end

  describe '#edit' do
    let(:method) { :get }
    let(:path)   { '/books//edit' }

    it { expect(controller).to respond_to(:edit).with(0).arguments }

    describe 'with format: :html' do
      it 'should redirect to the resource root' do
        controller.edit

        expect(renderer)
          .to have_received(:redirect_to)
          .with('/books', { status: 302 })
      end

      describe 'with an invalid resource id' do
        let(:book_id)      { (Book.last&.id || -1) + 1 }
        let(:path)         { "/books/#{book_id}/edit" }
        let(:query_params) { { 'id' => book_id } }

        it 'should redirect to the resource root' do
          controller.edit

          expect(renderer)
            .to have_received(:redirect_to)
            .with('/books', { status: 302 })
        end
      end

      wrap_context 'when there are many books' do
        describe 'with an invalid resource id' do
          let(:book_id)      { (Book.last&.id || -1) + 1 }
          let(:path)         { "/books/#{book_id}/edit" }
          let(:query_params) { { 'id' => book_id } }

          it 'should redirect to the resource root' do
            controller.edit

            expect(renderer)
              .to have_received(:redirect_to)
              .with('/books', { status: 302 })
          end
        end

        describe 'with a valid resource id' do
          let(:book)         { Book.where(title: 'The Tombs of Atuan').first }
          let(:book_id)      { book.id }
          let(:path)         { "/books/#{book_id}/edit" }
          let(:query_params) { { 'id' => book_id } }

          it 'should render the #edit view' do
            controller.edit

            expect(renderer)
              .to have_received(:render)
              .with(:edit, { status: 200 })
          end

          it 'should assign the book' do
            controller.edit

            expect(assigns).to deep_match({ '@book' => book })
          end
        end
      end
    end
  end

  describe '#index' do
    let(:method) { :get }
    let(:path)   { '/books' }

    it { expect(controller).to respond_to(:index).with(0).arguments }

    describe 'with format: :html' do
      it 'should render the #index view' do
        controller.index

        expect(renderer)
          .to have_received(:render)
          .with(:index, { status: 200 })
      end

      it 'should assign the queried books' do
        controller.index

        expect(assigns).to be == { '@books' => [] }
      end

      wrap_context 'when there are many books' do
        it 'should render the #index view' do
          controller.index

          expect(renderer)
            .to have_received(:render)
            .with(:index, { status: 200 })
        end

        it 'should assign the queried books' do
          controller.index

          expect(assigns).to deep_match({ '@books' => books })
        end
      end
    end

    describe 'with format :json' do
      let(:format) { :json }
      let(:path)   { '/books.json' }
      let(:data)   { { 'books' => [] } }
      let(:expected) do
        {
          'ok'   => true,
          'data' => data
        }
      end

      it 'should render the json' do
        controller.index

        expect(renderer)
          .to have_received(:render)
          .with(json: expected, status: 200)
      end

      wrap_context 'when there are many books' do
        let(:data) { { 'books' => books.map(&:as_json) } }

        it 'should render the json' do
          controller.index

          expect(renderer)
            .to have_received(:render)
            .with(json: expected, status: 200)
        end
      end
    end
  end

  describe '#new' do
    let(:method) { :get }
    let(:path)   { '/books/new' }

    it { expect(controller).to respond_to(:new).with(0).arguments }

    describe 'with format: :html' do
      let(:expected_book) { Book.new }

      it 'should render the #new view' do
        controller.new

        expect(renderer)
          .to have_received(:render)
          .with(:new, { status: 200 })
      end

      it 'should assign a new book' do
        controller.new

        expect(assigns).to deep_match({ '@book' => expected_book })
      end
    end
  end

  describe '#show' do
    let(:method) { :get }
    let(:path)   { '/books//' }

    it { expect(controller).to respond_to(:show).with(0).arguments }

    describe 'with format: :html' do
      it 'should redirect to the resource root' do
        controller.show

        expect(renderer)
          .to have_received(:redirect_to)
          .with('/books', { status: 302 })
      end

      describe 'with an invalid resource id' do
        let(:book_id)      { (Book.last&.id || -1) + 1 }
        let(:path)         { "/books/#{book_id}" }
        let(:query_params) { { 'id' => book_id } }

        it 'should redirect to the resource root' do
          controller.show

          expect(renderer)
            .to have_received(:redirect_to)
            .with('/books', { status: 302 })
        end
      end

      wrap_context 'when there are many books' do
        describe 'with an invalid resource id' do
          let(:book_id)      { (Book.last&.id || -1) + 1 }
          let(:path)         { "/books/#{book_id}" }
          let(:query_params) { { 'id' => book_id } }

          it 'should redirect to the resource root' do
            controller.show

            expect(renderer)
              .to have_received(:redirect_to)
              .with('/books', { status: 302 })
          end
        end

        describe 'with a valid resource id' do
          let(:book)         { Book.where(title: 'The Tombs of Atuan').first }
          let(:book_id)      { book.id }
          let(:path)         { "/books/#{book_id}" }
          let(:query_params) { { 'id' => book_id } }

          it 'should render the #show view' do
            controller.show

            expect(renderer)
              .to have_received(:render)
              .with(:show, { status: 200 })
          end

          it 'should assign the book' do
            controller.show

            expect(assigns).to deep_match({ '@book' => book })
          end
        end
      end
    end

    describe 'with format: :json' do
      let(:format) { :json }
      let(:path)   { '/books.json' }
      let(:error) do
        Cuprum::Error.new(
          message: 'Something went wrong when processing the request'
        )
      end
      let(:expected) do
        {
          'ok'    => false,
          'error' => error.as_json
        }
      end

      it 'should render the json' do
        controller.show

        expect(renderer)
          .to have_received(:render)
          .with(json: expected, status: 500)
      end

      describe 'with an invalid resource id' do
        let(:book_id)      { (Book.last&.id || -1) + 1 }
        let(:path)         { "/books/#{book_id}.json" }
        let(:query_params) { { 'id' => book_id } }
        let(:error) do
          Cuprum::Collections::Errors::NotFound.new(
            collection_name:    'books',
            primary_key_name:   :id,
            primary_key_values: [book_id]
          )
        end

        it 'should render the json' do
          controller.show

          expect(renderer)
            .to have_received(:render)
            .with(json: expected, status: 404)
        end
      end

      wrap_context 'when there are many books' do
        describe 'with an invalid resource id' do
          let(:book_id)      { (Book.last&.id || -1) + 1 }
          let(:path)         { "/books/#{book_id}" }
          let(:query_params) { { 'id' => book_id } }
          let(:error) do
            Cuprum::Collections::Errors::NotFound.new(
              collection_name:    'books',
              primary_key_name:   :id,
              primary_key_values: [book_id]
            )
          end

          it 'should render the json' do
            controller.show

            expect(renderer)
              .to have_received(:render)
              .with(json: expected, status: 404)
          end
        end

        describe 'with a valid resource id' do
          let(:book)         { Book.where(title: 'The Tombs of Atuan').first }
          let(:book_id)      { book.id }
          let(:path)         { "/books/#{book_id}" }
          let(:query_params) { { 'id' => book_id } }
          let(:expected) do
            {
              'ok'   => true,
              'data' => { 'book' => book.as_json }
            }
          end

          it 'should render the json' do
            controller.show

            expect(renderer)
              .to have_received(:render)
              .with(json: expected, status: 200)
          end
        end
      end
    end
  end

  describe '#update' do
    let(:method) { :patch }
    let(:path)   { '/books//' }

    it { expect(controller).to respond_to(:update).with(0).arguments }

    describe 'with format: :html' do
      it 'should redirect to the resource root' do
        controller.update

        expect(renderer)
          .to have_received(:redirect_to)
          .with('/books', { status: 302 })
      end

      describe 'with an invalid resource id' do
        let(:book_id)      { (Book.last&.id || -1) + 1 }
        let(:path)         { "/books/#{book_id}" }
        let(:query_params) { { 'id' => book_id } }

        it 'should redirect to the resource root' do
          controller.update

          expect(renderer)
            .to have_received(:redirect_to)
            .with('/books', { status: 302 })
        end
      end

      wrap_context 'when there are many books' do
        describe 'with an invalid resource id' do
          let(:book_id)      { (Book.last&.id || -1) + 1 }
          let(:path)         { "/books/#{book_id}" }
          let(:query_params) { { 'id' => book_id } }

          it 'should redirect to the resource root' do
            controller.update

            expect(renderer)
              .to have_received(:redirect_to)
              .with('/books', { status: 302 })
          end
        end

        describe 'with a valid resource id' do
          let(:book)         { Book.where(title: 'The Tombs of Atuan').first }
          let(:book_id)      { book.id }
          let(:path)         { "/books/#{book_id}" }
          let(:query_params) { { 'id' => book_id } }

          it 'should redirect to the resource root' do
            controller.update

            expect(renderer)
              .to have_received(:redirect_to)
              .with('/books', { status: 302 })
          end

          describe 'with invalid attributes' do
            let(:attributes) { { title: '' } }
            let(:params)     { super().merge(book: attributes) }
            let(:expected_book) do
              book.tap { book.assign_attributes(attributes) }
            end
            let(:expected_errors) do
              native_errors = expected_book.tap(&:valid?).errors

              Cuprum::Rails::MapErrors
                .instance
                .call(native_errors: native_errors)
            end
            let(:expected_assigns) do
              {
                '@book'   => expected_book,
                '@errors' => expected_errors
              }
            end

            it 'should render the #edit view' do
              controller.update

              expect(renderer)
                .to have_received(:render)
                .with(:edit, { status: 422 })
            end

            it 'should assign the book with the given attributes' do
              controller.update

              expect(assigns).to deep_match(expected_assigns)
            end

            it 'should not update the attributes' do
              expect { controller.update }
                .not_to(change { book.reload.attributes })
            end
          end

          describe 'with valid attributes' do
            let(:attributes) { { category: 'Coming of Age' } }
            let(:params)     { super().merge(book: attributes) }

            it 'should redirect to the show path' do
              controller.update

              expect(renderer)
                .to have_received(:redirect_to)
                .with("/books/#{book_id}", { status: 302 })
            end

            it 'should update the attributes' do
              expect { controller.update }
                .to change { book.reload.attributes }
                .to be >= attributes.stringify_keys
            end
          end
        end
      end
    end

    describe 'with format: :json' do
      let(:format) { :json }
      let(:path)   { '/books.json' }
      let(:error) do
        Cuprum::Error.new(
          message: 'Something went wrong when processing the request'
        )
      end
      let(:expected) do
        {
          'ok'    => false,
          'error' => error.as_json
        }
      end

      it 'should render the json' do
        controller.update

        expect(renderer)
          .to have_received(:render)
          .with(json: expected, status: 500)
      end

      describe 'with an invalid resource id' do
        let(:book_id)      { (Book.last&.id || -1) + 1 }
        let(:path)         { "/books/#{book_id}.json" }
        let(:query_params) { { 'id' => book_id } }
        let(:error) do
          Cuprum::Rails::Errors::MissingParameters
            .new(resource_name: 'book')
            .as_json
        end

        it 'should render the json' do
          controller.update

          expect(renderer)
            .to have_received(:render)
            .with(json: expected, status: 400)
        end

        describe 'with attributes' do
          let(:attributes) { { category: 'Coming of Age' } }
          let(:params)     { super().merge(book: attributes) }
          let(:error) do
            Cuprum::Collections::Errors::NotFound.new(
              collection_name:    'books',
              primary_key_name:   :id,
              primary_key_values: [book_id]
            )
          end

          it 'should render the json' do
            controller.update

            expect(renderer)
              .to have_received(:render)
              .with(json: expected, status: 404)
          end
        end
      end

      wrap_context 'when there are many books' do
        describe 'with an invalid resource id' do
          let(:book_id)      { (Book.last&.id || -1) + 1 }
          let(:path)         { "/books/#{book_id}.json" }
          let(:query_params) { { 'id' => book_id } }
          let(:error) do
            Cuprum::Rails::Errors::MissingParameters
              .new(resource_name: 'book')
              .as_json
          end

          it 'should render the json' do
            controller.update

            expect(renderer)
              .to have_received(:render)
              .with(json: expected, status: 400)
          end

          describe 'with attributes' do
            let(:attributes) { { category: 'Coming of Age' } }
            let(:params)     { super().merge(book: attributes) }
            let(:error) do
              Cuprum::Collections::Errors::NotFound.new(
                collection_name:    'books',
                primary_key_name:   :id,
                primary_key_values: [book_id]
              )
            end

            it 'should render the json' do
              controller.update

              expect(renderer)
                .to have_received(:render)
                .with(json: expected, status: 404)
            end
          end
        end

        describe 'with a valid resource id' do
          let(:book)         { Book.where(title: 'The Tombs of Atuan').first }
          let(:book_id)      { book.id }
          let(:path)         { "/books/#{book_id}" }
          let(:query_params) { { 'id' => book_id } }
          let(:error) do
            Cuprum::Rails::Errors::MissingParameters
              .new(resource_name: 'book')
              .as_json
          end

          it 'should render the json' do
            controller.update

            expect(renderer)
              .to have_received(:render)
              .with(json: expected, status: 400)
          end

          describe 'with invalid attributes' do
            let(:attributes) { { title: '' } }
            let(:params)     { super().merge(book: attributes) }
            let(:expected_book) do
              book.tap { book.assign_attributes(attributes) }
            end
            let(:expected_errors) do
              native_errors = expected_book.tap(&:valid?).errors

              Cuprum::Rails::MapErrors
                .instance
                .call(native_errors: native_errors)
            end
            let(:error) do
              Cuprum::Collections::Errors::FailedValidation.new(
                entity_class: Book,
                errors:       expected_errors
              )
            end

            it 'should render the json' do
              controller.update

              expect(renderer)
                .to have_received(:render)
                .with(json: expected, status: 422)
            end

            it 'should not update the attributes' do
              expect { controller.update }
                .not_to(change { book.reload.attributes })
            end
          end

          describe 'with valid attributes' do
            let(:attributes) { { category: 'Coming of Age' } }
            let(:params)     { super().merge(book: attributes) }
            let(:expected) do
              {
                'ok'   => true,
                'data' => { 'book' => book.reload.as_json }
              }
            end

            it 'should render the json' do
              controller.update

              expect(renderer)
                .to have_received(:render)
                .with(json: expected, status: 200)
            end

            it 'should update the attributes' do
              expect { controller.update }
                .to change { book.reload.attributes }
                .to be >= attributes.stringify_keys
            end
          end
        end
      end
    end
  end
  # rubocop:enable RSpec/NestedGroups
end
