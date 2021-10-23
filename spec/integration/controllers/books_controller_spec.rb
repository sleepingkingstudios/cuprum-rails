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

  let(:assigns) { controller.assigns }
  let(:format)  { :html }
  let(:params)  { {} }
  let(:renderer) do
    instance_double(Spec::Renderer, redirect_to: nil, render: nil)
  end
  let(:request) do
    instance_double(
      Spec::Request,
      format: instance_double(Mime::Type, symbol: format),
      params: params
    )
  end

  example_class 'Spec::Renderer' do |klass|
    klass.define_method(:redirect_to) { |*_, **_| nil }
    klass.define_method(:render)      { |*_, **_| nil }
  end

  example_class 'Spec::Request', Struct.new(:format, :params)

  # rubocop:disable RSpec/NestedGroups
  describe '#create' do
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
  end

  describe '#destroy' do
    it { expect(controller).to respond_to(:destroy).with(0).arguments }

    describe 'with format: :html' do
      it 'should redirect to the resource root' do
        controller.destroy

        expect(renderer)
          .to have_received(:redirect_to)
          .with('/books', { status: 302 })
      end

      describe 'with an invalid resource id' do
        let(:book_id) { (Book.last&.id || -1) + 1 }
        let(:params)  { super().merge(id: book_id) }

        it 'should redirect to the resource root' do
          controller.destroy

          expect(renderer)
            .to have_received(:redirect_to)
            .with('/books', { status: 302 })
        end
      end

      wrap_context 'when there are many books' do
        describe 'with an invalid resource id' do
          let(:book_id) { (Book.last&.id || -1) + 1 }
          let(:params)  { super().merge(id: book_id) }

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
          let(:book)    { Book.where(title: 'The Tombs of Atuan').first }
          let(:book_id) { book.id }
          let(:params)  { super().merge(id: book_id) }

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
  end

  describe '#edit' do
    it { expect(controller).to respond_to(:edit).with(0).arguments }

    describe 'with format: :html' do
      it 'should redirect to the resource root' do
        controller.edit

        expect(renderer)
          .to have_received(:redirect_to)
          .with('/books', { status: 302 })
      end

      describe 'with an invalid resource id' do
        let(:book_id) { (Book.last&.id || -1) + 1 }
        let(:params)  { super().merge(id: book_id) }

        it 'should redirect to the resource root' do
          controller.edit

          expect(renderer)
            .to have_received(:redirect_to)
            .with('/books', { status: 302 })
        end
      end

      wrap_context 'when there are many books' do
        describe 'with an invalid resource id' do
          let(:book_id) { (Book.last&.id || -1) + 1 }
          let(:params)  { super().merge(id: book_id) }

          it 'should redirect to the resource root' do
            controller.edit

            expect(renderer)
              .to have_received(:redirect_to)
              .with('/books', { status: 302 })
          end
        end

        describe 'with a valid resource id' do
          let(:book)    { Book.where(title: 'The Tombs of Atuan').first }
          let(:book_id) { book.id }
          let(:params)  { super().merge(id: book_id) }

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
  end

  describe '#new' do
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
    it { expect(controller).to respond_to(:show).with(0).arguments }

    describe 'with format: :html' do
      it 'should redirect to the resource root' do
        controller.show

        expect(renderer)
          .to have_received(:redirect_to)
          .with('/books', { status: 302 })
      end

      describe 'with an invalid resource id' do
        let(:book_id) { (Book.last&.id || -1) + 1 }
        let(:params)  { super().merge(id: book_id) }

        it 'should redirect to the resource root' do
          controller.show

          expect(renderer)
            .to have_received(:redirect_to)
            .with('/books', { status: 302 })
        end
      end

      wrap_context 'when there are many books' do
        describe 'with an invalid resource id' do
          let(:book_id) { (Book.last&.id || -1) + 1 }
          let(:params)  { super().merge(id: book_id) }

          it 'should redirect to the resource root' do
            controller.show

            expect(renderer)
              .to have_received(:redirect_to)
              .with('/books', { status: 302 })
          end
        end

        describe 'with a valid resource id' do
          let(:book)    { Book.where(title: 'The Tombs of Atuan').first }
          let(:book_id) { book.id }
          let(:params)  { super().merge(id: book_id) }

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
  end

  describe '#update' do
    it { expect(controller).to respond_to(:update).with(0).arguments }

    describe 'with format: :html' do
      it 'should redirect to the resource root' do
        controller.update

        expect(renderer)
          .to have_received(:redirect_to)
          .with('/books', { status: 302 })
      end

      describe 'with an invalid resource id' do
        let(:book_id) { (Book.last&.id || -1) + 1 }
        let(:params)  { super().merge(id: book_id) }

        it 'should redirect to the resource root' do
          controller.update

          expect(renderer)
            .to have_received(:redirect_to)
            .with('/books', { status: 302 })
        end
      end

      wrap_context 'when there are many books' do
        describe 'with an invalid resource id' do
          let(:book_id) { (Book.last&.id || -1) + 1 }
          let(:params)  { super().merge(id: book_id) }

          it 'should redirect to the resource root' do
            controller.update

            expect(renderer)
              .to have_received(:redirect_to)
              .with('/books', { status: 302 })
          end
        end

        describe 'with a valid resource id' do
          let(:book)    { Book.where(title: 'The Tombs of Atuan').first }
          let(:book_id) { book.id }
          let(:params)  { super().merge(id: book_id) }

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

            it 'should not update the attributes' do
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
