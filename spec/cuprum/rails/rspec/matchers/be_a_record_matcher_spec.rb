# frozen_string_literal: true

require 'rspec/matchers/fail_matchers'

require 'cuprum/rails/rspec/matchers/be_a_record_matcher'

require 'support/book'
require 'support/cover'
require 'support/tome'

RSpec.describe Cuprum::Rails::RSpec::Matchers::BeARecordMatcher do
  subject(:matcher) { described_class.new(expected) }

  deferred_context 'with an attributes expectation' do |**options|
    let(:expected_attributes) do
      {
        title:  'Gideon the Ninth',
        author: 'Tammsyn Muir'
      }
    end
    let(:expected_description) { "#{super()} with expected attributes" }
    let(:matcher) do
      super().with_attributes(expected_attributes, **options)
    end
  end

  let(:expected) { Book }

  define_method :tools do
    SleepingKingStudios::Tools::Toolbelt.instance
  end

  describe '.new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '#actual' do
    include_examples 'should define reader', :actual, nil

    context 'when the matcher has matched an object using #does_not_match?' do
      let(:actual) { Object.new.freeze }

      before { matcher.does_not_match?(actual) }

      it { expect(matcher.actual).to be actual }
    end

    context 'when the matcher has matched an object using #matches?' do
      let(:actual) { Object.new.freeze }

      before { matcher.matches?(actual) }

      it { expect(matcher.actual).to be actual }
    end
  end

  describe '#allow_extra_attributes?' do
    include_examples 'should define predicate', :allow_extra_attributes?, true

    wrap_deferred 'with an attributes expectation',
      allow_extra_attributes: false \
    do
      it { expect(matcher.allow_extra_attributes?).to be false }
    end

    # rubocop:disable RSpec/MetadataStyle
    wrap_deferred 'with an attributes expectation',
      allow_extra_attributes: true \
    do
      it { expect(matcher.allow_extra_attributes?).to be true }
    end
    # rubocop:enable RSpec/MetadataStyle
  end

  describe '#description' do
    let(:expected_description) { "be a #{expected.name}" }

    include_examples 'should define reader',
      :description,
      -> { expected_description }

    wrap_deferred 'with an attributes expectation' do
      it { expect(matcher.description).to be == expected_description }
    end

    context 'when initialized with a matcher' do
      let(:expected)             { be_a(super()) }
      let(:expected_description) { expected.description }

      it { expect(matcher.description).to be == expected_description }

      wrap_deferred 'with an attributes expectation' do
        it { expect(matcher.description).to be == expected_description }
      end
    end
  end

  describe '#does_not_match' do
    shared_examples 'should match' do |configured_actual|
      let(:actual) do
        next configured_actual unless configured_actual.is_a?(Proc)

        instance_exec(&configured_actual)
      end

      it { expect(matcher.does_not_match?(actual)).to be false }

      it 'should set the failure message' do
        matcher.does_not_match?(actual)

        expect(matcher.failure_message_when_negated).to be == failure_message
      end
    end

    shared_examples 'should not match' do |configured_actual|
      let(:actual) do
        next configured_actual unless configured_actual.is_a?(Proc)

        instance_exec(&configured_actual)
      end

      it { expect(matcher.does_not_match?(actual)).to be true }
    end

    let(:failure_message) do
      "expected #{actual.inspect} not to #{matcher.description}"
    end

    it { expect(matcher).to respond_to(:does_not_match?).with(1).argument }

    describe 'with nil' do
      include_examples 'should not match', nil
    end

    describe 'with an Object' do
      include_examples 'should not match', Object.new.freeze
    end

    describe 'with a non-matching record' do
      include_examples 'should not match', -> { Cover.new }
    end

    describe 'with a record with empty attributes' do
      include_examples 'should match', -> { Book.new }
    end

    describe 'with a record with non-empty attributes' do
      let(:other_attributes) { { title: 'Harrow the Ninth' } }

      include_examples 'should match', -> { Book.new(other_attributes) }
    end

    describe 'with an empty attributes expectation' do
      let(:expected_attributes) { {} }

      include_deferred 'with an attributes expectation'

      describe 'with a record with empty attributes' do
        include_examples 'should match', -> { Book.new }
      end

      describe 'with a record with non-empty attributes' do
        let(:other_attributes) { { title: 'Harrow the Ninth' } }

        include_examples 'should match', -> { Book.new(other_attributes) }
      end
    end

    wrap_deferred 'with an attributes expectation' do
      describe 'with nil' do
        include_examples 'should not match', nil
      end

      describe 'with an Object' do
        include_examples 'should not match', Object.new.freeze
      end

      describe 'with a non-matching record' do
        include_examples 'should not match', -> { Cover.new }
      end

      describe 'with a record with empty attributes' do
        include_examples 'should not match', -> { Book.new }
      end

      describe 'with a record with non-matching attributes' do
        let(:other_attributes) do
          {
            title:  'Harrow the Ninth',
            author: 'Tammsyn Muir'
          }
        end

        include_examples 'should not match', -> { Book.new(other_attributes) }
      end

      describe 'with a record with matching attributes' do
        include_examples 'should match', -> { Book.new(expected_attributes) }
      end

      describe 'with a record with extra attributes' do
        let(:other_attributes) do
          expected_attributes.merge(series: 'The Locked Tomb')
        end

        include_examples 'should match', -> { Book.new(other_attributes) }
      end
    end

    wrap_deferred 'with an attributes expectation',
      allow_extra_attributes: false \
    do
      describe 'with a record with extra attributes' do
        let(:other_attributes) do
          expected_attributes.merge(series: 'The Locked Tomb')
        end

        include_examples 'should not match', -> { Book.new(other_attributes) }
      end
    end

    describe 'with an attributes expectation with matcher values' do
      let(:expected_attributes) { super().merge(id: be_a(Integer)) }

      include_deferred 'with an attributes expectation'

      describe 'with a record with non-matching attributes' do
        let(:other_attributes) do
          {
            title:  'Harrow the Ninth',
            author: 'Tammsyn Muir'
          }
        end

        include_examples 'should not match', -> { Book.new(other_attributes) }
      end

      describe 'with a record with matching attributes' do
        let(:valid_attributes) { expected_attributes.merge(id: 0) }

        include_examples 'should match', -> { Book.new(valid_attributes) }
      end
    end

    describe 'with an attributes expectation with time values' do
      let(:expected_attributes) { super().merge(published_at: '2019-09-10') }

      include_deferred 'with an attributes expectation'

      describe 'with a record with non-matching attributes' do
        let(:other_attributes) do
          {
            title:        'Harrow the Ninth',
            author:       'Tammsyn Muir',
            published_at: Date.parse('2020-06-04')
          }
        end

        include_examples 'should not match', -> { Book.new(other_attributes) }
      end

      describe 'with a record with matching attributes' do
        let(:valid_attributes) do
          expected_attributes.merge(published_at: Date.parse('2019-09-10'))
        end

        include_examples 'should match', -> { Book.new(valid_attributes) }
      end
    end

    describe 'with a matcher expectation' do
      let(:expected_attributes) do
        be >= {
          'title'  => 'Gideon the Ninth',
          'author' => 'Tammsyn Muir'
        }
      end

      include_deferred 'with an attributes expectation'

      describe 'with a record with non-matching attributes' do
        let(:other_attributes) do
          {
            title:        'Harrow the Ninth',
            author:       'Tammsyn Muir',
            published_at: Date.parse('2020-06-04')
          }
        end

        include_examples 'should not match', -> { Book.new(other_attributes) }
      end

      describe 'with a record with matching attributes' do
        let(:valid_attributes) do
          {
            title:  'Gideon the Ninth',
            author: 'Tammsyn Muir'
          }
        end

        include_examples 'should match', -> { Book.new(valid_attributes) }
      end
    end

    context 'when initialized with expected: a record class with timestamps' do
      let(:expected) { Tome }

      wrap_deferred 'with an attributes expectation' do
        describe 'with a record with non-matching timestamps' do
          let(:created_at) { Time.zone.now }
          let(:updated_at) { Time.zone.now }
          let(:expected_attributes) do
            {
              title:      'Gideon the Ninth',
              author:     'Tammsyn Muir',
              created_at:,
              updated_at:
            }
          end
          let(:other_attributes) do
            {
              title:  'Gideon the Ninth',
              author: 'Tammsyn Muir'
            }
          end

          include_examples 'should match', -> { Tome.new(other_attributes) }
        end

        describe 'with a record with matching timestamps' do
          let(:expected_attributes) do
            {
              title:      'Gideon the Ninth',
              author:     'Tammsyn Muir',
              created_at: Time.zone.now,
              updated_at: Time.zone.now
            }
          end

          include_examples 'should match', -> { Tome.new(expected_attributes) }
        end

        describe 'with a record with extra timestamps' do
          let(:expected_attributes) do
            {
              title:  'Gideon the Ninth',
              author: 'Tammsyn Muir'
            }
          end
          let(:other_attributes) do
            {
              title:      'Gideon the Ninth',
              author:     'Tammsyn Muir',
              created_at: Time.zone.now,
              updated_at: Time.zone.now
            }
          end

          include_examples 'should match', -> { Tome.new(other_attributes) }
        end
      end

      wrap_deferred 'with an attributes expectation',
        ignore_timestamps: false \
      do
        describe 'with a record with non-matching timestamps' do
          let(:created_at) { Time.zone.now }
          let(:updated_at) { Time.zone.now }
          let(:expected_attributes) do
            {
              title:      'Gideon the Ninth',
              author:     'Tammsyn Muir',
              created_at:,
              updated_at:
            }
          end
          let(:other_attributes) do
            {
              title:  'Gideon the Ninth',
              author: 'Tammsyn Muir'
            }
          end

          include_examples 'should not match', -> { Tome.new(other_attributes) }
        end
      end

      wrap_deferred 'with an attributes expectation',
        allow_extra_attributes: false \
      do
        describe 'with a record with non-matching attributes' do
          let(:other_attributes) do
            {
              title:  'Harrow the Ninth',
              author: 'Tammsyn Muir'
            }
          end

          include_examples 'should not match', -> { Tome.new(other_attributes) }
        end

        describe 'with a record with matching attributes' do
          let(:expected_attributes) do
            {
              uuid:         nil,
              title:        'Gideon the Ninth',
              author:       'Tammsyn Muir',
              series:       nil,
              category:     nil,
              published_at: nil
            }
          end
          let(:other_attributes) do
            {
              title:  'Gideon the Ninth',
              author: 'Tammsyn Muir'
            }
          end

          include_examples 'should match', -> { Tome.new(other_attributes) }
        end

        describe 'with a record with extra attributes' do
          let(:other_attributes) do
            expected_attributes.merge(series: 'The Locked Tomb')
          end

          include_examples 'should not match', -> { Tome.new(other_attributes) }
        end
      end

      wrap_deferred 'with an attributes expectation',
        allow_extra_attributes: false,
        ignore_timestamps:      false \
      do
        describe 'with a record with non-matching attributes' do
          let(:other_attributes) do
            {
              title:  'Harrow the Ninth',
              author: 'Tammsyn Muir'
            }
          end

          include_examples 'should not match', -> { Tome.new(other_attributes) }
        end

        describe 'with a record with matching attributes' do
          let(:expected_attributes) do
            {
              uuid:         nil,
              title:        'Gideon the Ninth',
              author:       'Tammsyn Muir',
              series:       nil,
              category:     nil,
              published_at: nil,
              created_at:   nil,
              updated_at:   nil
            }
          end
          let(:other_attributes) do
            {
              title:  'Gideon the Ninth',
              author: 'Tammsyn Muir'
            }
          end

          include_examples 'should match', -> { Tome.new(other_attributes) }
        end

        describe 'with a record with extra attributes' do
          let(:other_attributes) do
            expected_attributes.merge(series: 'The Locked Tomb')
          end

          include_examples 'should not match', -> { Tome.new(other_attributes) }
        end
      end
    end

    context 'when initialized with expected: Hash' do
      let(:expected) { Hash }

      describe 'with nil' do
        include_examples 'should not match', nil
      end

      describe 'with an Object' do
        include_examples 'should not match', Object.new.freeze
      end

      describe 'with a record' do
        include_examples 'should not match', -> { Cover.new }
      end

      describe 'with an empty Hash' do
        include_examples 'should match', -> { {} }
      end

      describe 'with a non-empty Hash' do
        let(:other_attributes) { { title: 'Harrow the Ninth' } }

        include_examples 'should match', -> { other_attributes }
      end

      wrap_deferred 'with an attributes expectation' do
        describe 'with nil' do
          include_examples 'should not match', nil
        end

        describe 'with an Object' do
          include_examples 'should not match', Object.new.freeze
        end

        describe 'with a record' do
          include_examples 'should not match', -> { Cover.new }
        end

        describe 'with an empty Hash' do
          include_examples 'should not match', -> { {} }
        end

        describe 'with a non-matching Hash' do
          let(:other_attributes) do
            {
              title:  'Harrow the Ninth',
              author: 'Tammsyn Muir'
            }
          end

          include_examples 'should not match', -> { other_attributes }
        end

        describe 'with a matching Hash' do
          include_examples 'should match', -> { expected_attributes }
        end

        describe 'with a Hash with extra attributes' do
          let(:other_attributes) do
            expected_attributes.merge(series: 'The Locked Tomb')
          end

          include_examples 'should match', -> { other_attributes }
        end
      end

      wrap_deferred 'with an attributes expectation',
        allow_extra_attributes: false \
      do
        describe 'with a Hash with extra attributes' do
          let(:other_attributes) do
            expected_attributes.merge(series: 'The Locked Tomb')
          end

          include_examples 'should not match', -> { other_attributes }
        end
      end
    end

    context 'when initialized with expected: a matcher' do
      let(:expected)             { be_a(super()) }
      let(:expected_description) { expected.description }

      describe 'with nil' do
        include_examples 'should not match', nil
      end

      describe 'with an Object' do
        include_examples 'should not match', Object.new.freeze
      end

      describe 'with a non-matching record' do
        include_examples 'should not match', -> { Cover.new }
      end

      describe 'with a record with empty attributes' do
        include_examples 'should match', -> { Book.new }
      end

      describe 'with a record with non-empty attributes' do
        let(:attributes) { { title: 'Harrow the Ninth' } }

        include_examples 'should match', -> { Book.new(attributes) }
      end

      wrap_deferred 'with an attributes expectation' do
        describe 'with a record with non-matching attributes' do
          let(:other_attributes) do
            {
              title:  'Harrow the Ninth',
              author: 'Tammsyn Muir'
            }
          end

          include_examples 'should not match', -> { Book.new(other_attributes) }
        end

        describe 'with a record with matching attributes' do
          include_examples 'should match', -> { Book.new(expected_attributes) }
        end
      end
    end
  end

  describe '#expected' do
    include_examples 'should define reader', :expected, -> { expected }

    it { expect(matcher).to have_aliased_method(:expected).as(:record_class) }
  end

  describe '#expected_attributes' do
    include_examples 'should define reader', :expected_attributes, nil

    context 'with an attributes expectation with String keys' do
      let(:expected_attributes) { { 'title' => 'Gideon the Ninth' } }
      let(:matcher) do
        super().with_attributes(expected_attributes)
      end

      it 'should set the expected attributes' do
        expect(matcher.expected_attributes).to be == expected_attributes
      end
    end

    context 'with an attributes expectation with Symbol keys' do
      let(:expected_attributes) { { title: 'Gideon the Ninth' } }
      let(:matcher) do
        super().with_attributes(expected_attributes)
      end
      let(:expected_with_string_keys) do
        tools.hsh.convert_keys_to_strings(expected_attributes)
      end

      it 'should set the expected attributes' do
        expect(matcher.expected_attributes).to be == expected_with_string_keys
      end
    end
  end

  describe '#failure_message' do
    include_examples 'should define reader', :failure_message
  end

  describe '#failure_message_when_negated' do
    include_examples 'should define reader', :failure_message_when_negated
  end

  describe '#ignore_timestamps?' do
    include_examples 'should define predicate', :ignore_timestamps?, true

    wrap_deferred 'with an attributes expectation', ignore_timestamps: false do
      it { expect(matcher.ignore_timestamps?).to be false }
    end

    wrap_deferred 'with an attributes expectation', ignore_timestamps: true do # rubocop:disable RSpec/MetadataStyle
      it { expect(matcher.ignore_timestamps?).to be true }
    end
  end

  describe '#matches?' do
    shared_examples 'should match' do |configured_actual|
      let(:actual) do
        next configured_actual unless configured_actual.is_a?(Proc)

        instance_exec(&configured_actual)
      end

      it { expect(matcher.matches?(actual)).to be true }
    end

    shared_examples 'should not match' do |configured_actual|
      let(:actual) do
        next configured_actual unless configured_actual.is_a?(Proc)

        instance_exec(&configured_actual)
      end

      it { expect(matcher.matches?(actual)).to be false }

      it 'should set the failure message' do
        matcher.matches?(actual)

        expect(matcher.failure_message).to be == failure_message
      end
    end

    let(:failure_message) do
      "expected #{actual.inspect} to #{matcher.description}"
    end

    it { expect(matcher).to respond_to(:matches?).with(1).argument }

    describe 'with nil' do
      let(:failure_message) { "#{super()}, but is nil" }

      include_examples 'should not match', nil
    end

    describe 'with an Object' do
      let(:failure_message) { "#{super()}, but is an instance of Object" }

      include_examples 'should not match', Object.new.freeze
    end

    describe 'with a non-matching record' do
      let(:failure_message) { "#{super()}, but is an instance of Cover" }

      include_examples 'should not match', -> { Cover.new }
    end

    describe 'with a record with empty attributes' do
      include_examples 'should match', -> { Book.new }
    end

    describe 'with a record with non-empty attributes' do
      let(:other_attributes) { { title: 'Harrow the Ninth' } }

      include_examples 'should match', -> { Book.new(other_attributes) }
    end

    describe 'with an empty attributes expectation' do
      let(:expected_attributes) { {} }

      include_deferred 'with an attributes expectation'

      describe 'with a record with empty attributes' do
        include_examples 'should match', -> { Book.new }
      end

      describe 'with a record with non-empty attributes' do
        let(:other_attributes) { { title: 'Harrow the Ninth' } }

        include_examples 'should match', -> { Book.new(other_attributes) }
      end
    end

    wrap_deferred 'with an attributes expectation' do
      describe 'with nil' do
        let(:failure_message) { "#{super()}, but is nil" }

        include_examples 'should not match', nil
      end

      describe 'with an Object' do
        let(:failure_message) { "#{super()}, but is an instance of Object" }

        include_examples 'should not match', Object.new.freeze
      end

      describe 'with a non-matching record' do
        let(:failure_message) { "#{super()}, but is an instance of Cover" }

        include_examples 'should not match', -> { Cover.new }
      end

      describe 'with a record with empty attributes' do
        let(:failure_message) do
          <<~MESSAGE
            #{super()}, but the attributes do not match:

              id: nil
            - title: "Gideon the Ninth"
            + title: ""
            - author: "Tammsyn Muir"
            + author: ""
              series: nil
              category: nil
              published_at: nil
          MESSAGE
        end

        include_examples 'should not match', -> { Book.new }
      end

      describe 'with a record with non-matching attributes' do
        let(:other_attributes) do
          {
            title:  'Harrow the Ninth',
            author: 'Tammsyn Muir'
          }
        end
        let(:failure_message) do
          <<~MESSAGE
            #{super()}, but the attributes do not match:

              id: nil
            - title: "Gideon the Ninth"
            + title: "Harrow the Ninth"
              author: "Tammsyn Muir"
              series: nil
              category: nil
              published_at: nil
          MESSAGE
        end

        include_examples 'should not match', -> { Book.new(other_attributes) }
      end

      describe 'with a record with matching attributes' do
        include_examples 'should match', -> { Book.new(expected_attributes) }
      end

      describe 'with a record with extra attributes' do
        let(:other_attributes) do
          expected_attributes.merge(series: 'The Locked Tomb')
        end

        include_examples 'should match', -> { Book.new(other_attributes) }
      end
    end

    wrap_deferred 'with an attributes expectation',
      allow_extra_attributes: false \
    do
      describe 'with a record with extra attributes' do
        let(:other_attributes) do
          expected_attributes.merge(series: 'The Locked Tomb')
        end
        let(:failure_message) do
          <<~MESSAGE
            #{super()}, but the attributes do not match:

            + id: nil
              title: "Gideon the Ninth"
              author: "Tammsyn Muir"
            + series: "The Locked Tomb"
            + category: nil
            + published_at: nil
          MESSAGE
        end

        include_examples 'should not match', -> { Book.new(other_attributes) }
      end
    end

    describe 'with an attributes expectation with matcher values' do
      let(:expected_attributes) { super().merge(id: be_a(Integer)) }

      include_deferred 'with an attributes expectation'

      describe 'with a record with non-matching attributes' do
        let(:other_attributes) do
          {
            title:  'Harrow the Ninth',
            author: 'Tammsyn Muir'
          }
        end
        let(:failure_message) do
          <<~MESSAGE
            #{super()}, but the attributes do not match:

            - id: be a Integer
            + id: nil
            - title: "Gideon the Ninth"
            + title: "Harrow the Ninth"
              author: "Tammsyn Muir"
              series: nil
              category: nil
              published_at: nil
          MESSAGE
        end

        include_examples 'should not match', -> { Book.new(other_attributes) }
      end

      describe 'with a record with matching attributes' do
        let(:valid_attributes) { expected_attributes.merge(id: 0) }

        include_examples 'should match', -> { Book.new(valid_attributes) }
      end
    end

    describe 'with an attributes expectation with time values' do
      let(:expected_attributes) { super().merge(published_at: '2019-09-10') }

      include_deferred 'with an attributes expectation'

      describe 'with a record with non-matching attributes' do
        let(:other_attributes) do
          {
            title:        'Harrow the Ninth',
            author:       'Tammsyn Muir',
            published_at: Date.parse('2020-06-04')
          }
        end
        let(:failure_message) do
          <<~MESSAGE
            #{super()}, but the attributes do not match:

              id: nil
            - title: "Gideon the Ninth"
            + title: "Harrow the Ninth"
              author: "Tammsyn Muir"
              series: nil
              category: nil
            - published_at: "2019-09-10"
            + published_at: #{actual.published_at.inspect}
          MESSAGE
        end

        include_examples 'should not match', -> { Book.new(other_attributes) }
      end

      describe 'with a record with matching attributes' do
        let(:valid_attributes) do
          expected_attributes.merge(published_at: Date.parse('2019-09-10'))
        end

        include_examples 'should match', -> { Book.new(valid_attributes) }
      end
    end

    describe 'with a matcher expectation' do
      let(:expected_attributes) do
        be >= {
          'title'  => 'Gideon the Ninth',
          'author' => 'Tammsyn Muir'
        }
      end

      include_deferred 'with an attributes expectation'

      describe 'with a record with non-matching attributes' do
        let(:other_attributes) do
          {
            title:        'Harrow the Ninth',
            author:       'Tammsyn Muir',
            published_at: Date.parse('2020-06-04')
          }
        end
        let(:failure_message) do
          "#{super()}, but the attributes do not match: expected attributes " \
            "to #{expected_attributes.description}"
        end

        include_examples 'should not match', -> { Book.new(other_attributes) }
      end

      describe 'with a record with matching attributes' do
        let(:valid_attributes) do
          {
            title:  'Gideon the Ninth',
            author: 'Tammsyn Muir'
          }
        end

        include_examples 'should match', -> { Book.new(valid_attributes) }
      end
    end

    context 'when initialized with expected: a record class with timestamps' do
      let(:expected) { Tome }

      wrap_deferred 'with an attributes expectation' do
        describe 'with a record with non-matching timestamps' do
          let(:created_at) { Time.zone.now }
          let(:updated_at) { Time.zone.now }
          let(:expected_attributes) do
            {
              title:      'Gideon the Ninth',
              author:     'Tammsyn Muir',
              created_at:,
              updated_at:
            }
          end
          let(:other_attributes) do
            {
              title:  'Gideon the Ninth',
              author: 'Tammsyn Muir'
            }
          end

          include_examples 'should match', -> { Tome.new(other_attributes) }
        end

        describe 'with a record with matching timestamps' do
          let(:expected_attributes) do
            {
              title:      'Gideon the Ninth',
              author:     'Tammsyn Muir',
              created_at: Time.zone.now,
              updated_at: Time.zone.now
            }
          end

          include_examples 'should match', -> { Tome.new(expected_attributes) }
        end

        describe 'with a record with extra timestamps' do
          let(:expected_attributes) do
            {
              title:  'Gideon the Ninth',
              author: 'Tammsyn Muir'
            }
          end
          let(:other_attributes) do
            {
              title:      'Gideon the Ninth',
              author:     'Tammsyn Muir',
              created_at: Time.zone.now,
              updated_at: Time.zone.now
            }
          end

          include_examples 'should match', -> { Tome.new(other_attributes) }
        end
      end

      wrap_deferred 'with an attributes expectation',
        ignore_timestamps: false \
      do
        describe 'with a record with non-matching timestamps' do
          let(:created_at) { Time.zone.now }
          let(:updated_at) { Time.zone.now }
          let(:expected_attributes) do
            {
              title:      'Gideon the Ninth',
              author:     'Tammsyn Muir',
              created_at:,
              updated_at:
            }
          end
          let(:other_attributes) do
            {
              title:  'Gideon the Ninth',
              author: 'Tammsyn Muir'
            }
          end
          let(:failure_message) do
            <<~MESSAGE
              #{super()}, but the attributes do not match:

                uuid: nil
                title: "Gideon the Ninth"
                author: "Tammsyn Muir"
                series: nil
                category: nil
                published_at: nil
              - created_at: #{created_at.inspect}
              + created_at: nil
              - updated_at: #{updated_at.inspect}
              + updated_at: nil
            MESSAGE
          end

          include_examples 'should not match', -> { Tome.new(other_attributes) }
        end
      end

      wrap_deferred 'with an attributes expectation',
        allow_extra_attributes: false \
      do
        describe 'with a record with non-matching attributes' do
          let(:other_attributes) do
            {
              title:  'Harrow the Ninth',
              author: 'Tammsyn Muir'
            }
          end
          let(:failure_message) do
            <<~MESSAGE
              #{super()}, but the attributes do not match:

              + uuid: nil
              - title: "Gideon the Ninth"
              + title: "Harrow the Ninth"
                author: "Tammsyn Muir"
              + series: nil
              + category: nil
              + published_at: nil
                created_at: nil
                updated_at: nil
            MESSAGE
          end

          include_examples 'should not match', -> { Tome.new(other_attributes) }
        end

        describe 'with a record with matching attributes' do
          let(:expected_attributes) do
            {
              uuid:         nil,
              title:        'Gideon the Ninth',
              author:       'Tammsyn Muir',
              series:       nil,
              category:     nil,
              published_at: nil
            }
          end
          let(:other_attributes) do
            {
              title:  'Gideon the Ninth',
              author: 'Tammsyn Muir'
            }
          end

          include_examples 'should match', -> { Tome.new(other_attributes) }
        end

        describe 'with a record with extra attributes' do
          let(:other_attributes) do
            expected_attributes.merge(series: 'The Locked Tomb')
          end
          let(:failure_message) do
            <<~MESSAGE
              #{super()}, but the attributes do not match:

              + uuid: nil
                title: "Gideon the Ninth"
                author: "Tammsyn Muir"
              + series: "The Locked Tomb"
              + category: nil
              + published_at: nil
                created_at: nil
                updated_at: nil
            MESSAGE
          end

          include_examples 'should not match', -> { Tome.new(other_attributes) }
        end
      end

      wrap_deferred 'with an attributes expectation',
        allow_extra_attributes: false,
        ignore_timestamps:      false \
      do
        describe 'with a record with non-matching attributes' do
          let(:other_attributes) do
            {
              title:  'Harrow the Ninth',
              author: 'Tammsyn Muir'
            }
          end
          let(:failure_message) do
            <<~MESSAGE
              #{super()}, but the attributes do not match:

              + uuid: nil
              - title: "Gideon the Ninth"
              + title: "Harrow the Ninth"
                author: "Tammsyn Muir"
              + series: nil
              + category: nil
              + published_at: nil
              + created_at: nil
              + updated_at: nil
            MESSAGE
          end

          include_examples 'should not match', -> { Tome.new(other_attributes) }
        end

        describe 'with a record with matching attributes' do
          let(:expected_attributes) do
            {
              uuid:         nil,
              title:        'Gideon the Ninth',
              author:       'Tammsyn Muir',
              series:       nil,
              category:     nil,
              published_at: nil,
              created_at:   nil,
              updated_at:   nil
            }
          end
          let(:other_attributes) do
            {
              title:  'Gideon the Ninth',
              author: 'Tammsyn Muir'
            }
          end

          include_examples 'should match', -> { Tome.new(other_attributes) }
        end

        describe 'with a record with extra attributes' do
          let(:other_attributes) do
            expected_attributes.merge(series: 'The Locked Tomb')
          end
          let(:failure_message) do
            <<~MESSAGE
              #{super()}, but the attributes do not match:

              + uuid: nil
                title: "Gideon the Ninth"
                author: "Tammsyn Muir"
              + series: "The Locked Tomb"
              + category: nil
              + published_at: nil
              + created_at: nil
              + updated_at: nil
            MESSAGE
          end

          include_examples 'should not match', -> { Tome.new(other_attributes) }
        end
      end
    end

    context 'when initialized with expected: Hash' do
      let(:expected) { Hash }

      describe 'with nil' do
        let(:failure_message) { "#{super()}, but is nil" }

        include_examples 'should not match', nil
      end

      describe 'with an Object' do
        let(:failure_message) { "#{super()}, but is an instance of Object" }

        include_examples 'should not match', Object.new.freeze
      end

      describe 'with a record' do
        let(:failure_message) { "#{super()}, but is an instance of Cover" }

        include_examples 'should not match', -> { Cover.new }
      end

      describe 'with an empty Hash' do
        include_examples 'should match', -> { {} }
      end

      describe 'with a non-empty Hash' do
        let(:other_attributes) { { title: 'Harrow the Ninth' } }

        include_examples 'should match', -> { other_attributes }
      end

      wrap_deferred 'with an attributes expectation' do
        describe 'with nil' do
          let(:failure_message) { "#{super()}, but is nil" }

          include_examples 'should not match', nil
        end

        describe 'with an Object' do
          let(:failure_message) { "#{super()}, but is an instance of Object" }

          include_examples 'should not match', Object.new.freeze
        end

        describe 'with a record' do
          let(:failure_message) { "#{super()}, but is an instance of Cover" }

          include_examples 'should not match', -> { Cover.new }
        end

        describe 'with an empty Hash' do
          let(:failure_message) do
            <<~MESSAGE
              #{super()}, but the attributes do not match:

              - title: "Gideon the Ninth"
              - author: "Tammsyn Muir"
            MESSAGE
          end

          include_examples 'should not match', -> { {} }
        end

        describe 'with a non-matching Hash' do
          let(:other_attributes) do
            {
              title:  'Harrow the Ninth',
              author: 'Tammsyn Muir'
            }
          end
          let(:failure_message) do
            <<~MESSAGE
              #{super()}, but the attributes do not match:

              - title: "Gideon the Ninth"
              + title: "Harrow the Ninth"
                author: "Tammsyn Muir"
            MESSAGE
          end

          include_examples 'should not match', -> { other_attributes }
        end

        describe 'with a matching Hash' do
          include_examples 'should match', -> { expected_attributes }
        end

        describe 'with a Hash with extra attributes' do
          let(:other_attributes) do
            expected_attributes.merge(series: 'The Locked Tomb')
          end

          include_examples 'should match', -> { other_attributes }
        end
      end

      wrap_deferred 'with an attributes expectation',
        allow_extra_attributes: false \
      do
        describe 'with a Hash with extra attributes' do
          let(:other_attributes) do
            expected_attributes.merge(series: 'The Locked Tomb')
          end
          let(:failure_message) do
            <<~MESSAGE
              #{super()}, but the attributes do not match:

                title: "Gideon the Ninth"
                author: "Tammsyn Muir"
              + series: "The Locked Tomb"
            MESSAGE
          end

          include_examples 'should not match', -> { other_attributes }
        end
      end
    end

    context 'when initialized with expected: a matcher' do
      let(:expected)             { be_a(super()) }
      let(:expected_description) { expected.description }

      describe 'with nil' do
        let(:failure_message) { "#{super()}, but is nil" }

        include_examples 'should not match', nil
      end

      describe 'with an Object' do
        let(:failure_message) { "#{super()}, but is an instance of Object" }

        include_examples 'should not match', Object.new.freeze
      end

      describe 'with a non-matching record' do
        let(:failure_message) { "#{super()}, but is an instance of Cover" }

        include_examples 'should not match', -> { Cover.new }
      end

      describe 'with a record with empty attributes' do
        include_examples 'should match', -> { Book.new }
      end

      describe 'with a record with non-empty attributes' do
        let(:attributes) { { title: 'Harrow the Ninth' } }

        include_examples 'should match', -> { Book.new(attributes) }
      end

      wrap_deferred 'with an attributes expectation' do
        describe 'with a record with non-matching attributes' do
          let(:other_attributes) do
            {
              title:  'Harrow the Ninth',
              author: 'Tammsyn Muir'
            }
          end
          let(:failure_message) do
            <<~MESSAGE
              #{super()}, but the attributes do not match:

                id: nil
              - title: "Gideon the Ninth"
              + title: "Harrow the Ninth"
                author: "Tammsyn Muir"
                series: nil
                category: nil
                published_at: nil
            MESSAGE
          end

          include_examples 'should not match', -> { Book.new(other_attributes) }
        end

        describe 'with a record with matching attributes' do
          include_examples 'should match', -> { Book.new(expected_attributes) }
        end
      end
    end
  end

  describe '#with_attributes' do
    let(:attributes) { { title: 'Gideon the Ninth' } }

    it 'should define the method' do
      expect(matcher)
        .to respond_to(:with_attributes)
        .with(1).argument
        .and_keywords(:allow_extra_attributes, :ignore_timestamps)
    end

    it { expect(matcher.with_attributes(attributes)).to be matcher }
  end
end
