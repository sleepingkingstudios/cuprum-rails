# frozen_string_literal: true

require 'cuprum/rails/actions/middleware/associations/find'
require 'cuprum/rails/records/repository'
require 'cuprum/rails/request'
require 'cuprum/rails/resource'

require 'support/book'
require 'support/chapter'
require 'support/cover'

RSpec.describe Cuprum::Rails::Actions::Middleware::Associations::Find do
  subject(:middleware) { described_class.new(**constructor_options) }

  let(:association_params)  { { name: 'chapters' } }
  let(:constructor_options) { association_params }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:association_type)
        .and_any_keywords
    end

    describe 'with invalid association params' do
      let(:association_params) { {} }
      let(:error_message) do
        "name or entity class can't be blank"
      end

      it 'should raise an exception' do
        expect { described_class.new(**constructor_options) }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '#association' do
    let(:association) { middleware.association }

    include_examples 'should define reader', :association

    it { expect(association).to be_a Cuprum::Collections::Association }

    it { expect(association.name).to be == association_params[:name] }

    context 'when initialized with association_type: :belongs_to' do
      let(:association_type) { :belongs_to }
      let(:association_class) do
        Cuprum::Collections::Associations::BelongsTo
      end
      let(:constructor_options) do
        super().merge(association_type:)
      end

      it { expect(association).to be_a association_class }
    end

    context 'when initialized with association params' do
      let(:association_params) do
        super().merge(
          primary_key_type: String,
          qualified_name:   'spec/scoped_books'
        )
      end

      it { expect(association.primary_key_type).to be String }

      it { expect(association.qualified_name).to be == 'spec/scoped_books' }
    end
  end

  describe '#association_type' do
    include_examples 'should define reader', :association_type, nil

    context 'when initialized with association_type: :belongs_to' do
      let(:association_type) { :belongs_to }
      let(:constructor_options) do
        super().merge(association_type:)
      end

      it { expect(middleware.association_type).to be == association_type }
    end
  end

  describe '#call' do
    shared_examples 'should call the next command' do
      it 'should call the next command' do # rubocop:disable RSpec/ExampleLength
        call_command

        expect(next_command)
          .to have_received(:call)
          .with(
            repository:,
            request:,
            resource:,
            **options
          )
      end

      context 'when called with custom options' do
        let(:options) do
          super().merge('custom_option' => 'custom value')
        end

        it 'should call the next command' do # rubocop:disable RSpec/ExampleLength
          call_command

          expect(next_command)
            .to have_received(:call)
            .with(
              repository:,
              request:,
              resource:,
              **options
            )
        end
      end
    end

    let(:next_value)   { { 'ok' => true } }
    let(:next_result)  { Cuprum::Result.new(value: next_value) }
    let(:next_command) { instance_double(Cuprum::Command, call: next_result) }
    let(:request)      { Cuprum::Rails::Request.new }
    let(:repository) do
      Cuprum::Rails::Records::Repository.new.tap do |repository|
        repository.create(entity_class: Book)
        repository.create(entity_class: Chapter)
        repository.create(entity_class: Cover)
      end
    end
    let(:resource)     { Cuprum::Rails::Resource.new(name: 'books') }
    let(:options)      { {} }

    def call_command
      middleware.call(
        next_command,
        repository:,
        request:,
        resource:,
        **options
      )
    end

    it 'should define the method' do
      expect(middleware)
        .to be_callable
        .with(1).argument
        .and_keywords(:repository, :request, :resource)
        .and_any_keywords
    end

    include_examples 'should call the next command'

    it 'should return the next command result' do
      expect(call_command)
        .to be_a_passing_result
        .with_value(next_value)
    end

    context 'when the next command returns one value' do
      let(:book) do
        Book.new(
          author: 'Tamsyn Muir',
          title:  'Gideon the Ninth'
        )
      end
      let(:next_value) { super().merge('book' => book) }

      before(:example) { book.save! }

      it 'should return the next command result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(next_value)
      end

      context 'when there are many associated values' do
        let(:chapters) do
          [
            Chapter.new(
              book:,
              title:         'Chapter 0',
              chapter_index: 0
            ),
            Chapter.new(
              book:,
              title:         'Chapter 1',
              chapter_index: 1
            ),
            Chapter.new(
              book:,
              title:         'Chapter 2',
              chapter_index: 2
            )
          ]
        end
        let(:expected) { next_value.merge('chapters' => chapters) }

        before(:example) { chapters.each(&:save!) }

        it 'should merge the association values' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected)
        end

        it 'should cache the association' do
          call_command

          expect(book.send(:association_instance_get, 'chapters'))
            .to be == chapters
        end

        context 'when the next command returns a failing result' do
          let(:next_result) do
            Cuprum::Result.new(status: :failure, value: next_value)
          end

          it 'should return the next command result' do
            expect(call_command)
              .to be_a_failing_result
              .with_value(next_value)
          end
        end
      end
    end

    context 'when the next command returns many values' do
      let(:books) do
        [
          Book.new(
            author: 'Tamsyn Muir',
            title:  'Gideon the Ninth'
          ),
          Book.new(
            author: 'Tamsyn Muir',
            title:  'Harrow the Ninth'
          ),
          Book.new(
            author: 'Tamsyn Muir',
            title:  'Nona the Ninth'
          )
        ]
      end
      let(:next_value) { super().merge('books' => books) }

      before(:example) { books.each(&:save!) }

      it 'should return the next command result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(next_value)
      end

      context 'when there are many associated values' do
        let(:chapters) do
          [
            Chapter.new(
              book:          books.first,
              title:         'Chapter 0',
              chapter_index: 0
            ),
            Chapter.new(
              book:          books.first,
              title:         'Chapter 1',
              chapter_index: 1
            ),
            Chapter.new(
              book:          books[1],
              title:         'Chapter 2',
              chapter_index: 2
            )
          ]
        end
        let(:expected) { next_value.merge('chapters' => chapters) }

        before(:example) { chapters.each(&:save!) }

        def chapters_for(book)
          chapters.select { |chapter| chapter.book_id == book.id }
        end

        it 'should merge the association values' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected)
        end

        it 'should cache the association', :aggregate_failures do
          call_command

          books.each do |book|
            expect(book.send(:association_instance_get, 'chapters'))
              .to be == chapters_for(book)
          end
        end

        context 'when the next command returns a failing result' do
          let(:next_result) do
            Cuprum::Result.new(status: :failure, value: next_value)
          end

          it 'should return the next command result' do
            expect(call_command)
              .to be_a_failing_result
              .with_value(next_value)
          end
        end
      end
    end

    context 'when initialized with association_type: :belongs_to' do
      let(:association_type)   { :belongs_to }
      let(:association_params) { { name: 'book' } }
      let(:constructor_options) do
        super().merge(association_type:)
      end
      let(:resource) { Cuprum::Rails::Resource.new(name: 'chapters') }

      it 'should return the next command result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(next_value)
      end

      context 'when the next command returns one value' do
        let(:book) do
          Book.new(
            author: 'Tamsyn Muir',
            title:  'Gideon the Ninth'
          )
        end
        let(:chapter) do
          Chapter.new(
            book:,
            title:         'Chapter 0',
            chapter_index: 0
          )
        end
        let(:next_value) { super().merge('chapter' => chapter) }
        let(:expected)   { next_value.merge('book' => book) }

        before(:example) do
          book.save!

          chapter.save!
        end

        it 'should merge the association value' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected)
        end

        it 'should cache the association' do
          call_command

          expect(chapter.send(:association_instance_get, 'book'))
            .to be == book
        end

        context 'when the next command returns a failing result' do
          let(:next_result) do
            Cuprum::Result.new(status: :failure, value: next_value)
          end

          it 'should return the next command result' do
            expect(call_command)
              .to be_a_failing_result
              .with_value(next_value)
          end
        end
      end

      context 'when the next command returns many values' do
        let(:books) do
          [
            Book.new(
              author: 'Tamsyn Muir',
              title:  'Gideon the Ninth'
            ),
            Book.new(
              author: 'Tamsyn Muir',
              title:  'Harrow the Ninth'
            )
          ]
        end
        let(:chapters) do
          [
            Chapter.new(
              book:          books.first,
              title:         'Chapter 0',
              chapter_index: 0
            ),
            Chapter.new(
              book:          books.first,
              title:         'Chapter 1',
              chapter_index: 1
            ),
            Chapter.new(
              book:          books.last,
              title:         'Chapter 0',
              chapter_index: 0
            )
          ]
        end
        let(:next_value) { super().merge('chapters' => chapters) }
        let(:expected)   { next_value.merge('books' => books) }

        before(:example) do
          books.each(&:save!)

          chapters.each(&:save!)
        end

        def book_for(chapter)
          books.find { |book| book.id == chapter.book_id }
        end

        it 'should merge the association values' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected)
        end

        it 'should cache the association', :aggregate_failures do
          call_command

          chapters.each do |chapter|
            expect(chapter.send(:association_instance_get, 'book'))
              .to be == book_for(chapter)
          end
        end

        context 'when the next command returns a failing result' do
          let(:next_result) do
            Cuprum::Result.new(status: :failure, value: next_value)
          end

          it 'should return the next command result' do
            expect(call_command)
              .to be_a_failing_result
              .with_value(next_value)
          end
        end
      end
    end

    context 'when initialized with association_type: :has_one' do
      let(:association_params) { { name: 'cover', singular: true } }

      it 'should return the next command result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(next_value)
      end

      context 'when the next command returns one value' do
        let(:book) do
          Book.new(
            author: 'Tamsyn Muir',
            title:  'Gideon the Ninth'
          )
        end
        let(:next_value) { super().merge('book' => book) }

        before(:example) { book.save! }

        it 'should return the next command result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(next_value)
        end

        context 'when there is one associated value' do
          let(:cover) do
            Cover.new(
              book:,
              artist: 'Tommy Arnold'
            )
          end
          let(:expected) { next_value.merge('cover' => cover) }

          before(:example) { cover.save! }

          it 'should merge the association values' do
            expect(call_command)
              .to be_a_passing_result
              .with_value(expected)
          end

          it 'should cache the association' do
            call_command

            expect(book.send(:association_instance_get, 'cover'))
              .to be == cover
          end

          context 'when the next command returns a failing result' do # rubocop:disable RSpec/NestedGroups
            let(:next_result) do
              Cuprum::Result.new(status: :failure, value: next_value)
            end

            it 'should return the next command result' do
              expect(call_command)
                .to be_a_failing_result
                .with_value(next_value)
            end
          end
        end
      end

      context 'when the next command returns many values' do
        let(:books) do
          [
            Book.new(
              author: 'Tamsyn Muir',
              title:  'Gideon the Ninth'
            ),
            Book.new(
              author: 'Tamsyn Muir',
              title:  'Harrow the Ninth'
            ),
            Book.new(
              author: 'Tamsyn Muir',
              title:  'Nona the Ninth'
            )
          ]
        end
        let(:next_value) { super().merge('books' => books) }

        before(:example) { books.each(&:save!) }

        it 'should return the next command result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(next_value)
        end

        context 'when there are many associated values' do
          let(:covers) do
            [
              Cover.new(
                book:   books[0],
                artist: 'Tommy Arnold'
              ),
              Cover.new(
                book:   books[1],
                artist: 'Tommy Arnold'
              ),
              Cover.new(
                book:   books[2],
                artist: 'Tommy Arnold'
              )
            ]
          end
          let(:expected) { next_value.merge('covers' => covers) }

          before(:example) { covers.each(&:save!) }

          def cover_for(book)
            covers.find { |cover| cover.book_id == book.id }
          end

          it 'should merge the association values' do
            expect(call_command)
              .to be_a_passing_result
              .with_value(expected)
          end

          it 'should cache the association', :aggregate_failures do
            call_command

            books.each do |book|
              expect(book.send(:association_instance_get, 'cover'))
                .to be == cover_for(book)
            end
          end

          context 'when the next command returns a failing result' do # rubocop:disable RSpec/NestedGroups
            let(:next_result) do
              Cuprum::Result.new(status: :failure, value: next_value)
            end

            it 'should return the next command result' do
              expect(call_command)
                .to be_a_failing_result
                .with_value(next_value)
            end
          end
        end
      end
    end
  end
end
