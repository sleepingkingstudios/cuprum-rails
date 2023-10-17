# frozen_string_literal: true

require 'cuprum/collections/association'
require 'cuprum/collections/associations/belongs_to'

require 'cuprum/rails/actions/middleware/associations/cache'
require 'cuprum/rails/resource'

require 'support/book'
require 'support/chapter'
require 'support/cover'

RSpec.describe Cuprum::Rails::Actions::Middleware::Associations::Cache do
  subject(:command) do
    described_class.new(association: association, resource: resource)
  end

  shared_context 'when a custom strategy is defined' do
    let(:custom_strategy) do
      lambda do |entity:, name:, value:|
        entity.associations[name] = value

        entity
      end
    end

    example_class 'Spec::ExampleEntity' do |klass|
      klass.define_method(:initialize) do |**attributes|
        @attributes   = attributes.stringify_keys
        @associations = {}
      end

      klass.attr_reader :associations

      klass.attr_reader :attributes

      klass.define_method(:[]) do |key|
        @attributes.fetch(key.to_s) { @associations[key.to_s] } # rubocop:disable RSpec/InstanceVariable
      end
    end

    around(:example) do |example|
      strategies = described_class.instance_variable_get(:@strategies).dup

      described_class.define_strategy(Spec::ExampleEntity, &custom_strategy)

      example.call
    ensure
      described_class.instance_variable_set(:@strategies, strategies)
    end
  end

  let(:association) { Cuprum::Collections::Association.new(name: 'chapters') }
  let(:resource)    { Cuprum::Rails::Resource.new(name: 'books') }

  describe '::ACTIVE_RECORD_STRATEGY' do
    let(:entity) do
      Book.create(
        'author' => 'Tamsyn Muir',
        'title'  => 'Gideon the Ninth'
      )
    end
    let(:name) { 'chapters' }
    let(:value) do
      [
        Chapter.create(
          'book_id'       => entity.id,
          'chapter_index' => 0
        ),
        Chapter.create(
          'book_id'       => entity.id,
          'chapter_index' => 1
        )
      ]
    end

    def call_strategy
      described_class::ACTIVE_RECORD_STRATEGY.call(
        entity: entity,
        name:   name,
        value:  value
      )
    end

    include_examples 'should define constant', :ACTIVE_RECORD_STRATEGY

    it { expect(call_strategy).to be entity }

    it 'should cache the association' do
      expect(call_strategy.send(:association_instance_get, name))
        .to be == value
    end
  end

  describe '::DEFAULT_STRATEGY' do
    let(:entity) do
      {
        'id'     => 0,
        'author' => 'Tamsyn Muir',
        'title'  => 'Gideon the Ninth'
      }
    end
    let(:name) { 'chapters' }
    let(:value) do
      [
        {
          'id'            => 0,
          'book_id'       => 0,
          'chapter_index' => 0
        },
        {
          'id'            => 1,
          'book_id'       => 0,
          'chapter_index' => 1
        }
      ]
    end
    let(:expected) do
      entity.merge('chapters' => value)
    end

    def call_strategy
      described_class::DEFAULT_STRATEGY.call(
        entity: entity,
        name:   name,
        value:  value
      )
    end

    include_examples 'should define constant', :DEFAULT_STRATEGY

    it { expect(call_strategy).to be == expected }
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:association, :resource)
    end
  end

  describe '.define_strategy' do
    let(:struct_strategy) do
      # :nocov:
      lambda do |entity:, name:, value:|
        entity.send(:"#{name}=", value)

        entity
      end
      # :nocov:
    end

    around(:example) do |example|
      strategies = described_class.instance_variable_get(:@strategies).dup

      example.call
    ensure
      described_class.instance_variable_set(:@strategies, strategies)
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:define_strategy)
        .with(1).argument
        .and_a_block
    end

    it 'should prepend the strategy to strategies' do
      described_class.define_strategy(Struct, &struct_strategy)

      expect(described_class.strategies.first)
        .to be == [Struct, struct_strategy]
    end
  end

  describe '.strategies' do
    let(:expected) do
      [
        [
          ActiveRecord::Base,
          described_class::ACTIVE_RECORD_STRATEGY
        ],
        [
          Object,
          described_class::DEFAULT_STRATEGY
        ]
      ]
    end

    include_examples 'should define class reader', :strategies

    it 'should enumerate the defined strategies' do
      expect(described_class.strategies.to_a).to be == expected
    end

    wrap_context 'when a custom strategy is defined' do
      let(:expected) do
        [
          [
            Spec::ExampleEntity,
            custom_strategy
          ],
          *super()
        ]
      end

      it 'should enumerate the defined strategies' do
        expect(described_class.strategies.to_a).to be == expected
      end
    end
  end

  describe '#association' do
    include_examples 'should define reader', :association, -> { association }
  end

  describe '#call' do
    let(:entities) { [] }
    let(:values)   { [] }

    def call_command
      command.call(entities: entities, values: values)
    end

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:entities, :values)
    end

    it 'should return the entities' do
      expect(call_command)
        .to be_a_passing_result
        .with_value(entities)
    end

    describe 'with one entity' do
      let(:entities) do
        [
          {
            'id'     => 0,
            'author' => 'Tamsyn Muir',
            'title'  => 'Gideon the Ninth'
          }
        ]
      end

      def call_command
        command.call(entities: entities.first, values: values)
      end

      it 'should return the entity' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(entities.first)
      end

      describe 'with many values' do
        let(:values) do
          [
            {
              'id'            => 0,
              'book_id'       => 0,
              'chapter_index' => 0
            },
            {
              'id'            => 1,
              'book_id'       => 0,
              'chapter_index' => 1
            },
            {
              'id'            => 2,
              'book_id'       => 1,
              'chapter_index' => 0
            }
          ]
        end
        let(:expected) do
          entity = entities.first

          entity.merge('chapters' => chapters_for(entity['id']))
        end

        def chapters_for(book_id)
          values.select { |chapter| chapter['book_id'] == book_id }
        end

        it 'should cache the association and return the entities' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected)
        end
      end
    end

    describe 'with one record' do
      let(:entities) do
        [
          Book.create(
            'author' => 'Tamsyn Muir',
            'title'  => 'Gideon the Ninth'
          )
        ]
      end

      def call_command
        command.call(entities: entities.first, values: values)
      end

      it 'should return the entities' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(entities.first)
      end

      describe 'with many values' do
        let(:values) do
          [
            Chapter.create(
              'book_id'       => entities[0].id,
              'chapter_index' => 0
            ),
            Chapter.create(
              'book_id'       => entities[0].id,
              'chapter_index' => 1
            )
          ]
        end

        def chapters_for(book_id)
          values.select { |chapter| chapter['book_id'] == book_id }
        end

        it 'should return the entities' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(entities.first)
        end

        it 'should cache the associations' do
          entity = call_command.value

          expect(entity.send(:association_instance_get, 'chapters'))
            .to be == chapters_for(entity.id)
        end
      end
    end

    describe 'with many entities' do
      let(:entities) do
        [
          {
            'id'     => 0,
            'author' => 'Tamsyn Muir',
            'title'  => 'Gideon the Ninth'
          },
          {
            'id'     => 1,
            'author' => 'Tamsyn Muir',
            'title'  => 'Harrow the Ninth'
          },
          {
            'id'     => 2,
            'author' => 'Ursula K. LeGuin',
            'title'  => 'The Word For World Is Forest'
          }
        ]
      end

      it 'should return the entities' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(entities)
      end

      describe 'with many values' do
        let(:values) do
          [
            {
              'id'            => 0,
              'book_id'       => 0,
              'chapter_index' => 0
            },
            {
              'id'            => 1,
              'book_id'       => 0,
              'chapter_index' => 1
            },
            {
              'id'            => 2,
              'book_id'       => 1,
              'chapter_index' => 0
            }
          ]
        end
        let(:expected) do
          entities.map do |entity|
            entity.merge('chapters' => chapters_for(entity['id']))
          end
        end

        def chapters_for(book_id)
          values.select { |chapter| chapter['book_id'] == book_id }
        end

        it 'should cache the association and return the entities' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected)
        end
      end
    end

    describe 'with many records' do
      let(:entities) do
        [
          Book.create(
            'author' => 'Tamsyn Muir',
            'title'  => 'Gideon the Ninth'
          ),
          Book.create(
            'author' => 'Tamsyn Muir',
            'title'  => 'Harrow the Ninth'
          ),
          Book.create(
            'author' => 'Ursula K. LeGuin',
            'title'  => 'The Word For World Is Forest'
          )
        ]
      end

      it 'should return the entities' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(entities)
      end

      describe 'with many values' do
        let(:values) do
          [
            Chapter.create(
              'book_id'       => entities[0].id,
              'chapter_index' => 0
            ),
            Chapter.create(
              'book_id'       => entities[0].id,
              'chapter_index' => 1
            ),
            Chapter.create(
              'book_id'       => entities[1].id,
              'chapter_index' => 2
            )
          ]
        end

        def chapters_for(book_id)
          values.select { |chapter| chapter['book_id'] == book_id }
        end

        it 'should return the entities' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(entities)
        end

        it 'should cache the associations', :aggregate_failures do
          call_command.value.each do |entity|
            expect(entity.send(:association_instance_get, 'chapters'))
              .to be == chapters_for(entity.id)
          end
        end
      end
    end

    # rubocop:disable RSpec/NestedGroups
    context 'when initialized with association: a belongs_to association' do
      let(:association) do
        Cuprum::Collections::Associations::BelongsTo.new(
          name:     'book',
          singular: true
        )
      end
      let(:resource) { Cuprum::Rails::Resource.new(name: 'chapters') }

      it 'should return the entities' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(entities)
      end

      describe 'with many entities' do
        let(:entities) do
          [
            {
              'id'            => 0,
              'book_id'       => 0,
              'chapter_index' => 0
            },
            {
              'id'            => 1,
              'book_id'       => 0,
              'chapter_index' => 1
            },
            {
              'id'            => 2,
              'book_id'       => 1,
              'chapter_index' => 0
            }
          ]
        end

        it 'should return the entities' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(entities)
        end

        describe 'with many values' do
          let(:values) do
            [
              {
                'id'     => 0,
                'author' => 'Tamsyn Muir',
                'title'  => 'Gideon the Ninth'
              },
              {
                'id'     => 1,
                'author' => 'Tamsyn Muir',
                'title'  => 'Harrow the Ninth'
              },
              {
                'id'     => 2,
                'author' => 'Ursula K. LeGuin',
                'title'  => 'The Word For World Is Forest'
              }
            ]
          end

          let(:expected) do
            entities.map do |entity|
              entity.merge('book' => book_for(entity['book_id']))
            end
          end

          def book_for(book_id)
            values.find { |book| book['id'] == book_id }
          end

          it 'should cache the association and return the entities' do
            expect(call_command)
              .to be_a_passing_result
              .with_value(expected)
          end
        end
      end

      describe 'with many records' do
        let(:books) do
          [
            Book.create(
              'author' => 'Tamsyn Muir',
              'title'  => 'Gideon the Ninth'
            ),
            Book.create(
              'author' => 'Tamsyn Muir',
              'title'  => 'Harrow the Ninth'
            ),
            Book.create(
              'author' => 'Ursula K. LeGuin',
              'title'  => 'The Word For World Is Forest'
            )
          ]
        end
        let(:entities) do
          [
            Chapter.create(
              'book_id'       => books[0].id,
              'chapter_index' => 0
            ),
            Chapter.create(
              'book_id'       => books[0].id,
              'chapter_index' => 1
            ),
            Chapter.create(
              'book_id'       => books[1].id,
              'chapter_index' => 0
            )
          ]
        end

        it 'should return the entities' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(entities)
        end

        describe 'with many values' do
          let(:values) { books }

          def book_for(book_id)
            values.find { |book| book['id'] == book_id }
          end

          it 'should return the entities' do
            expect(call_command)
              .to be_a_passing_result
              .with_value(entities)
          end

          it 'should cache the associations', :aggregate_failures do
            call_command.value.each do |entity|
              expect(entity.send(:association_instance_get, 'book'))
                .to be == book_for(entity.book_id)
            end
          end
        end
      end

      context 'when initialized with resource: a singular resource' do
        let(:resource) do
          Cuprum::Rails::Resource.new(
            name:     'chapter',
            singular: true
          )
        end

        def call_command
          command.call(entities: entities.first, values: values.first)
        end

        it 'should return the entities' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(nil)
        end

        describe 'with one entity' do
          let(:entities) do
            [
              {
                'id'            => 0,
                'book_id'       => 0,
                'chapter_index' => 0
              }
            ]
          end

          it 'should return the entities' do
            expect(call_command)
              .to be_a_passing_result
              .with_value(entities.first)
          end

          describe 'with one value' do
            let(:values) do
              [
                {
                  'id'     => 0,
                  'author' => 'Tamsyn Muir',
                  'title'  => 'Gideon the Ninth'
                }
              ]
            end

            let(:expected) do
              entity = entities.first

              entity.merge('book' => book_for(entity['book_id']))
            end

            def book_for(book_id)
              values.find { |book| book['id'] == book_id }
            end

            it 'should cache the association and return the entities' do
              expect(call_command)
                .to be_a_passing_result
                .with_value(expected)
            end
          end
        end

        describe 'with one record' do
          let(:books) do
            [
              Book.create(
                'author' => 'Tamsyn Muir',
                'title'  => 'Gideon the Ninth'
              )
            ]
          end
          let(:entities) do
            [
              Chapter.create(
                'book_id'       => books[0].id,
                'chapter_index' => 0
              )
            ]
          end

          it 'should return the entities' do
            expect(call_command)
              .to be_a_passing_result
              .with_value(entities.first)
          end

          describe 'with one value' do
            let(:values) { books }

            def book_for(book_id)
              values.find { |book| book['id'] == book_id }
            end

            it 'should return the entities' do
              expect(call_command)
                .to be_a_passing_result
                .with_value(entities.first)
            end

            it 'should cache the association' do
              entity = call_command.value

              expect(entity.send(:association_instance_get, 'book'))
                .to be == book_for(entity.book_id)
            end
          end
        end
      end
    end

    context 'when initialized with association: a singular association' do
      let(:association) do
        Cuprum::Collections::Association.new(
          name:     'cover',
          singular: true
        )
      end

      it 'should return the entities' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(entities)
      end

      describe 'with many entities' do
        let(:entities) do
          [
            {
              'id'     => 0,
              'author' => 'Tamsyn Muir',
              'title'  => 'Gideon the Ninth'
            },
            {
              'id'     => 1,
              'author' => 'Tamsyn Muir',
              'title'  => 'Harrow the Ninth'
            },
            {
              'id'     => 2,
              'author' => 'Ursula K. LeGuin',
              'title'  => 'The Word For World Is Forest'
            }
          ]
        end

        it 'should return the entities' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(entities)
        end

        describe 'with many values' do
          let(:values) do
            [
              {
                'id'      => 0,
                'book_id' => 0,
                'artist'  => 'Tommy Arnold'
              },
              {
                'id'      => 1,
                'book_id' => 1,
                'artist'  => 'Tommy Arnold'
              },
              {
                'id'      => 2,
                'book_id' => 2,
                'artist'  => '  Richard M. Powers'
              }
            ]
          end
          let(:expected) do
            entities.map do |entity|
              entity.merge('cover' => cover_for(entity['id']))
            end
          end

          def cover_for(book_id)
            values.find { |cover| cover['book_id'] == book_id }
          end

          it 'should cache the association and return the entities' do
            expect(call_command)
              .to be_a_passing_result
              .with_value(expected)
          end
        end
      end

      describe 'with many records' do
        let(:entities) do
          [
            Book.create(
              'author' => 'Tamsyn Muir',
              'title'  => 'Gideon the Ninth'
            ),
            Book.create(
              'author' => 'Tamsyn Muir',
              'title'  => 'Harrow the Ninth'
            ),
            Book.create(
              'author' => 'Ursula K. LeGuin',
              'title'  => 'The Word For World Is Forest'
            )
          ]
        end

        it 'should return the entities' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(entities)
        end

        describe 'with many values' do
          let(:values) do
            [
              Cover.create(
                'book_id' => entities[0].id,
                'artist'  => 'Tommy Arnold'
              ),
              Cover.create(
                'book_id' => entities[1].id,
                'artist'  => 'Tommy Arnold'
              )
            ]
          end

          def cover_for(book_id)
            values.find { |cover| cover['book_id'] == book_id }
          end

          it 'should return the entities' do
            expect(call_command)
              .to be_a_passing_result
              .with_value(entities)
          end

          it 'should cache the associations', :aggregate_failures do
            call_command.value.each do |entity|
              expect(entity.send(:association_instance_get, 'cover'))
                .to be == cover_for(entity.id)
            end
          end
        end
      end

      context 'when initialized with resource: a singular resource' do
        let(:resource) do
          Cuprum::Rails::Resource.new(name: 'book', singular: true)
        end

        def call_command
          command.call(entities: entities.first, values: values.first)
        end

        it 'should return the entities' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(entities.first)
        end

        describe 'with one entity' do
          let(:entities) do
            [
              {
                'id'     => 0,
                'author' => 'Tamsyn Muir',
                'title'  => 'Gideon the Ninth'
              }
            ]
          end

          it 'should return the entities' do
            expect(call_command)
              .to be_a_passing_result
              .with_value(entities.first)
          end

          describe 'with one value' do
            let(:values) do
              [
                {
                  'id'      => 0,
                  'book_id' => 0,
                  'artist'  => 'Tommy Arnold'
                }
              ]
            end
            let(:expected) do
              entity = entities.first

              entity.merge('cover' => cover_for(entity['id']))
            end

            def cover_for(book_id)
              values.find { |cover| cover['book_id'] == book_id }
            end

            it 'should cache the association and return the entities' do
              expect(call_command)
                .to be_a_passing_result
                .with_value(expected)
            end
          end
        end

        describe 'with one record' do
          let(:entities) do
            [
              Book.create(
                'author' => 'Tamsyn Muir',
                'title'  => 'Gideon the Ninth'
              )
            ]
          end

          it 'should return the entities' do
            expect(call_command)
              .to be_a_passing_result
              .with_value(entities.first)
          end

          describe 'with one value' do
            let(:values) do
              [
                Cover.create(
                  'book_id' => entities[0].id,
                  'artist'  => 'Tommy Arnold'
                )
              ]
            end

            def cover_for(book_id)
              values.find { |cover| cover['book_id'] == book_id }
            end

            it 'should return the entities' do
              expect(call_command)
                .to be_a_passing_result
                .with_value(entities.first)
            end

            it 'should cache the associations', :aggregate_failures do
              entity = call_command.value

              expect(entity.send(:association_instance_get, 'cover'))
                .to be == cover_for(entity.id)
            end
          end
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups

    context 'when initialized with resource: a singular resource' do
      let(:resource) do
        Cuprum::Rails::Resource.new(name: 'book', singular: true)
      end

      def call_command
        command.call(entities: entities.first, values: values)
      end

      it 'should return the entities' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(nil)
      end

      describe 'with one entity' do
        let(:entities) do
          [
            {
              'id'     => 0,
              'author' => 'Tamsyn Muir',
              'title'  => 'Gideon the Ninth'
            }
          ]
        end

        it 'should return the entity' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(entities.first)
        end

        describe 'with many values' do
          let(:values) do
            [
              {
                'id'            => 0,
                'book_id'       => 0,
                'chapter_index' => 0
              },
              {
                'id'            => 1,
                'book_id'       => 0,
                'chapter_index' => 1
              }
            ]
          end
          let(:expected) do
            entity = entities.first

            entity.merge('chapters' => chapters_for(entity['id']))
          end

          def chapters_for(book_id)
            values.select { |chapter| chapter['book_id'] == book_id }
          end

          it 'should cache the association and return the entities' do
            expect(call_command)
              .to be_a_passing_result
              .with_value(expected)
          end
        end
      end

      describe 'with one record' do
        let(:entities) do
          [
            Book.create(
              'author' => 'Tamsyn Muir',
              'title'  => 'Gideon the Ninth'
            )
          ]
        end

        it 'should return the entities' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(entities.first)
        end

        describe 'with many values' do
          let(:values) do
            [
              Chapter.create(
                'book_id'       => entities[0].id,
                'chapter_index' => 0
              ),
              Chapter.create(
                'book_id'       => entities[0].id,
                'chapter_index' => 1
              )
            ]
          end

          def chapters_for(book_id)
            values.select { |chapter| chapter['book_id'] == book_id }
          end

          it 'should return the entities' do
            expect(call_command)
              .to be_a_passing_result
              .with_value(entities.first)
          end

          it 'should cache the association' do
            entity = call_command.value

            expect(entity.send(:association_instance_get, 'chapters'))
              .to be == chapters_for(entity.id)
          end
        end
      end
    end

    wrap_context 'when a custom strategy is defined' do
      it 'should return the entities' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(entities)
      end

      describe 'with many entities' do
        let(:entities) do
          [
            {
              'id'     => 0,
              'author' => 'Tamsyn Muir',
              'title'  => 'Gideon the Ninth'
            },
            {
              'id'     => 1,
              'author' => 'Tamsyn Muir',
              'title'  => 'Harrow the Ninth'
            },
            {
              'id'     => 2,
              'author' => 'Ursula K. LeGuin',
              'title'  => 'The Word For World Is Forest'
            }
          ]
        end

        it 'should return the entities' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(entities)
        end

        describe 'with many values' do
          let(:values) do
            [
              {
                'id'            => 0,
                'book_id'       => 0,
                'chapter_index' => 0
              },
              {
                'id'            => 1,
                'book_id'       => 0,
                'chapter_index' => 1
              },
              {
                'id'            => 2,
                'book_id'       => 1,
                'chapter_index' => 0
              }
            ]
          end
          let(:expected) do
            entities.map do |entity|
              entity.merge('chapters' => chapters_for(entity['id']))
            end
          end

          def chapters_for(book_id)
            values.select { |chapter| chapter['book_id'] == book_id }
          end

          it 'should cache the association and return the entities' do
            expect(call_command)
              .to be_a_passing_result
              .with_value(expected)
          end
        end
      end

      describe 'with many records' do
        let(:entities) do
          [
            Book.create(
              'author' => 'Tamsyn Muir',
              'title'  => 'Gideon the Ninth'
            ),
            Book.create(
              'author' => 'Tamsyn Muir',
              'title'  => 'Harrow the Ninth'
            ),
            Book.create(
              'author' => 'Ursula K. LeGuin',
              'title'  => 'The Word For World Is Forest'
            )
          ]
        end

        it 'should return the entities' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(entities)
        end

        describe 'with many values' do
          let(:values) do
            [
              Chapter.create(
                'book_id'       => entities[0].id,
                'chapter_index' => 0
              ),
              Chapter.create(
                'book_id'       => entities[0].id,
                'chapter_index' => 1
              ),
              Chapter.create(
                'book_id'       => entities[1].id,
                'chapter_index' => 2
              )
            ]
          end

          def chapters_for(book_id)
            values.select { |chapter| chapter['book_id'] == book_id }
          end

          it 'should return the entities' do
            expect(call_command)
              .to be_a_passing_result
              .with_value(entities)
          end

          it 'should cache the associations', :aggregate_failures do
            call_command.value.each do |entity|
              expect(entity.send(:association_instance_get, 'chapters'))
                .to be == chapters_for(entity.id)
            end
          end
        end
      end

      describe 'with many custom objects' do
        let(:entities) do
          [
            Spec::ExampleEntity.new(
              'id'     => 0,
              'author' => 'Tamsyn Muir',
              'title'  => 'Gideon the Ninth'
            ),
            Spec::ExampleEntity.new(
              'id'     => 1,
              'author' => 'Tamsyn Muir',
              'title'  => 'Harrow the Ninth'
            ),
            Spec::ExampleEntity.new(
              'id'     => 2,
              'author' => 'Ursula K. LeGuin',
              'title'  => 'The Word For World Is Forest'
            )
          ]
        end

        it 'should return the entities' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(entities)
        end

        describe 'with many values' do
          let(:values) do
            [
              Spec::ExampleEntity.new(
                'book_id'       => entities[0]['id'],
                'chapter_index' => 0
              ),
              Spec::ExampleEntity.new(
                'book_id'       => entities[0]['id'],
                'chapter_index' => 1
              ),
              Spec::ExampleEntity.new(
                'book_id'       => entities[1]['id'],
                'chapter_index' => 2
              )
            ]
          end

          def chapters_for(book_id)
            values.select { |chapter| chapter['book_id'] == book_id }
          end

          it 'should return the entities' do
            expect(call_command)
              .to be_a_passing_result
              .with_value(entities)
          end

          it 'should cache the associations', :aggregate_failures do
            call_command.value.each do |entity|
              expect(entity.associations['chapters'])
                .to be == chapters_for(entity['id'])
            end
          end
        end
      end
    end
  end

  describe '#resource' do
    include_examples 'should define reader', :resource, -> { resource }
  end
end
