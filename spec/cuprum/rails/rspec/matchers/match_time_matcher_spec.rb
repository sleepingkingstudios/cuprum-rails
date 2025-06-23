# frozen_string_literal: true

require 'cuprum/rails/rspec/matchers/match_time_matcher'

RSpec.describe Cuprum::Rails::RSpec::Matchers::MatchTimeMatcher do
  subject(:matcher) { described_class.new(expected) }

  shared_context 'when initialized with a time in UTC' do
    let(:time_zone)    { 'UTC' }
    let(:time_string)  { '1982-07-09T00:00:00' }
    let(:time_parts)   { [1982, 7, 9, 0, 0, 0] }
    let(:other_zone)   { 'Eastern Time (US & Canada)' }
    let(:other_string) { '1982-07-08T19:00:00' }
    let(:other_parts)  { [1982, 7, 8, 19, 0, 0] }
  end

  shared_context 'when initialized with a time outside UTC' do
    let(:time_zone)    { 'Eastern Time (US & Canada)' }
    let(:time_string)  { '1982-07-08T19:00:00' }
    let(:time_parts)   { [1982, 7, 8, 19, 0, 0] }
    let(:other_zone)   { 'UTC' }
    let(:other_string) { '1982-07-09T00:00:00' }
    let(:other_parts)  { [1982, 7, 9, 0, 0, 0] }
  end

  define_method :offset_string do |time_zone|
    time = Time.at(0, in: 'Z').in_time_zone(time_zone)

    time.utc? ? '+00:00' : time.formatted_offset(true)
  end

  let(:expected) { nil }

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

  describe '#description' do
    let(:expected_description) { "match time #{expected.inspect}" }

    include_examples 'should define reader',
      :description,
      -> { expected_description }
  end

  # rubocop:disable Rails/TimeZone
  describe '#does_not_match?' do
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

    shared_examples 'should compare the times' do
      describe 'with nil' do
        let(:failure_message) do
          "#{super()}, but the actual value is not a valid time"
        end

        include_examples 'should match', nil
      end

      describe 'with an Object' do
        let(:failure_message) do
          "#{super()}, but the actual value is not a valid time"
        end

        include_examples 'should match', Object.new.freeze
      end

      describe 'with an invalid String' do
        let(:failure_message) do
          "#{super()}, but the actual value is not a valid time"
        end

        include_examples 'should match', '1982-07-32'
      end

      describe 'with a non-matching Integer' do
        include_examples 'should not match', -> { Time.utc(2010, 12, 17).to_i }
      end

      describe 'with a matching Integer' do
        include_examples 'should match', -> { Time.utc(1982, 7, 9).to_i }
      end

      describe 'with a non-matching date String' do
        include_examples 'should not match', '2010-12-17'
      end

      describe 'with a matching date String' do
        include_examples 'should match', '1982-07-09'
      end

      describe 'with a non-matching datetime String without time zone' do
        include_examples 'should not match', '2010-12-17T00:00:00'
      end

      describe 'with a non-matching datetime String in a different time zone' do
        include_examples 'should not match',
          -> { "2010-12-17T00:00:00#{offset_string(other_zone)}" }
      end

      describe 'with a non-matching datetime String in the same time zone' do
        include_examples 'should not match',
          -> { "2010-12-17T00:00:00#{offset_string(time_zone)}" }
      end

      describe 'with a matching datetime String without time zone' do
        include_examples 'should match', '1982-07-09T00:00:00'
      end

      describe 'with a matching datetime String in a different time zone' do
        include_examples 'should match',
          -> { "#{other_string}#{offset_string(other_zone)}" }
      end

      describe 'with a matching datetime String in the same time zone' do
        include_examples 'should match',
          -> { "#{time_string}#{offset_string(time_zone)}" }
      end

      describe 'with a non-matching Date' do
        include_examples 'should not match', Date.new(2010, 12, 17)
      end

      describe 'with a matching Date' do
        include_examples 'should match', Date.new(1982, 7, 9)
      end

      describe 'with a non-matching DateTime in a different time zone' do
        let(:date_time) do
          DateTime.parse("2010-12-17T00:00:00#{offset_string(other_zone)}")
        end

        include_examples 'should not match', -> { date_time }
      end

      describe 'with a non-matching DateTime in the same time zone' do
        let(:date_time) do
          DateTime.parse("2010-12-17T00:00:00#{offset_string(time_zone)}")
        end

        include_examples 'should not match', -> { date_time }
      end

      describe 'with a matching DateTime in a different time zone' do
        let(:date_time) do
          DateTime.parse("#{other_string}#{offset_string(other_zone)}")
        end

        include_examples 'should match', -> { date_time }
      end

      describe 'with a matching DateTimein the same time zone' do
        let(:date_time) do
          DateTime.parse("#{time_string}#{offset_string(time_zone)}")
        end

        include_examples 'should match', -> { date_time }
      end

      describe 'with a non-matching Time in a different time zone' do
        let(:time) do
          Time.new(2010, 12, 17, 0, 0, 0, offset_string(other_zone))
        end

        include_examples 'should not match', -> { time }
      end

      describe 'with a non-matching Time in the same time zone' do
        let(:time) do
          Time.new(2010, 12, 17, 0, 0, 0, offset_string(time_zone))
        end

        include_examples 'should not match', -> { time }
      end

      describe 'with a matching Time in a different time zone' do
        let(:time) do
          Time.new(*other_parts, offset_string(other_zone))
        end

        include_examples 'should match', -> { time }
      end

      describe 'with a matching Time in the same time zone' do
        let(:time) do
          Time.new(*time_parts, offset_string(time_zone))
        end

        include_examples 'should match', -> { time }
      end

      describe 'with a non-matching TimeWithZone in different time zone' do
        let(:time_with_zone) do
          Date.new(2010, 12, 17)
            .in_time_zone('UTC')
            .in_time_zone(other_zone)
        end

        include_examples 'should not match', -> { time_with_zone }
      end

      describe 'with a non-matching TimeWithZone in the same time zone' do
        let(:time_with_zone) do
          Date.new(2010, 12, 17)
            .in_time_zone('UTC')
            .in_time_zone(time_zone)
        end

        include_examples 'should not match', -> { time_with_zone }
      end

      describe 'with a matching TimeWithZone in different time zone' do
        let(:time_with_zone) do
          Date.new(1982, 7, 9)
            .in_time_zone('UTC')
            .in_time_zone(other_zone)
        end

        include_examples 'should match', -> { time_with_zone }
      end

      describe 'with a matching TimeWithZone in the same time zone' do
        let(:time_with_zone) do
          Date.new(1982, 7, 9)
            .in_time_zone('UTC')
            .in_time_zone(time_zone)
        end

        include_examples 'should match', -> { time_with_zone }
      end
    end

    let(:failure_message) do
      "expected #{actual.inspect} not to #{matcher.description}"
    end

    it { expect(matcher).to respond_to(:does_not_match?).with(1).argument }

    context 'when initialized with expected: nil' do
      let(:expected) { nil }
      let(:failure_message) do
        "#{super()}, but the expected value is not a valid time"
      end

      describe 'with an Object' do
        include_examples 'should match', Object.new.freeze
      end

      describe 'with a Time' do
        include_examples 'should match', Time.now
      end
    end

    context 'when initialized with expected: an Object' do
      let(:expected) { Object.new.freeze }
      let(:failure_message) do
        "#{super()}, but the expected value is not a valid time"
      end

      describe 'with an Object' do
        include_examples 'should match', Object.new.freeze
      end

      describe 'with a Time' do
        include_examples 'should match', Time.now
      end
    end

    context 'when initialized with expected: an invalid String' do
      let(:expected) { '1982-07-32' }
      let(:failure_message) do
        "#{super()}, but the expected value is not a valid time"
      end

      describe 'with an Object' do
        include_examples 'should match', Object.new.freeze
      end

      describe 'with a Time' do
        include_examples 'should match', Time.now
      end
    end

    context 'when initialized with expected: an Integer' do
      include_context 'when initialized with a time in UTC'

      let(:expected) do
        Time.new(*time_parts, offset_string(time_zone)).to_i
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a date String' do
      include_context 'when initialized with a time in UTC'

      let(:expected) do
        '1982-07-09'
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a String without time zone' do
      include_context 'when initialized with a time in UTC'

      let(:expected) do
        '1982-07-09T00:00:00'
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a String in UTC' do
      include_context 'when initialized with a time in UTC'

      let(:expected) do
        "#{time_string}#{offset_string(time_zone)}"
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a String outside UTC' do
      include_context 'when initialized with a time outside UTC'

      let(:expected) do
        "#{time_string}#{offset_string(time_zone)}"
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a Date' do
      include_context 'when initialized with a time in UTC'

      let(:expected) do
        Date.new(1982, 7, 9)
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a DateTime in UTC' do
      include_context 'when initialized with a time in UTC'

      let(:expected) do
        DateTime.parse("#{time_string}#{offset_string(time_zone)}")
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a DateTime outside UTC' do
      include_context 'when initialized with a time outside UTC'

      let(:expected) do
        DateTime.parse("#{time_string}#{offset_string(time_zone)}")
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a Time in UTC' do
      include_context 'when initialized with a time in UTC'

      let(:expected) do
        Time.new(*time_parts, offset_string(time_zone))
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a Time outside UTC' do
      include_context 'when initialized with a time outside UTC'

      let(:expected) do
        Time.new(*time_parts, offset_string(time_zone))
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a TimeWithZone in UTC' do
      include_context 'when initialized with a time in UTC'

      let(:expected) do
        Time.new(*time_parts, offset_string(time_zone)).in_time_zone(time_zone)
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a TimeWithZone outside UTC' do
      include_context 'when initialized with a time outside UTC'

      let(:expected) do
        Time.new(*time_parts, offset_string(time_zone)).in_time_zone(time_zone)
      end

      include_examples 'should compare the times'
    end
  end
  # rubocop:enable Rails/TimeZone

  describe '#expected' do
    include_examples 'should define reader', :expected, -> { expected }
  end

  describe '#failure_message' do
    include_examples 'should define reader', :failure_message
  end

  describe '#failure_message_when_negated' do
    include_examples 'should define reader', :failure_message_when_negated
  end

  # rubocop:disable Rails/TimeZone
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

    shared_examples 'should compare the times' do
      describe 'with nil' do
        let(:failure_message) do
          "#{super()}, but the actual value is not a valid time"
        end

        include_examples 'should not match', nil
      end

      describe 'with an Object' do
        let(:failure_message) do
          "#{super()}, but the actual value is not a valid time"
        end

        include_examples 'should not match', Object.new.freeze
      end

      describe 'with an invalid String' do
        let(:failure_message) do
          "#{super()}, but the actual value is not a valid time"
        end

        include_examples 'should not match', '1982-07-32'
      end

      describe 'with a non-matching Integer' do
        let(:failure_message) { "#{super()}, but the times do not match" }

        include_examples 'should not match', -> { Time.utc(2010, 12, 17).to_i }
      end

      describe 'with a matching Integer' do
        include_examples 'should match', -> { Time.utc(1982, 7, 9).to_i }
      end

      describe 'with a non-matching date String' do
        let(:failure_message) { "#{super()}, but the times do not match" }

        include_examples 'should not match', '2010-12-17'
      end

      describe 'with a matching date String' do
        include_examples 'should match', '1982-07-09'
      end

      describe 'with a non-matching datetime String without time zone' do
        let(:failure_message) { "#{super()}, but the times do not match" }

        include_examples 'should not match', '2010-12-17T00:00:00'
      end

      describe 'with a non-matching datetime String in a different time zone' do
        let(:failure_message) { "#{super()}, but the times do not match" }

        include_examples 'should not match',
          -> { "2010-12-17T00:00:00#{offset_string(other_zone)}" }
      end

      describe 'with a non-matching datetime String in the same time zone' do
        let(:failure_message) { "#{super()}, but the times do not match" }

        include_examples 'should not match',
          -> { "2010-12-17T00:00:00#{offset_string(time_zone)}" }
      end

      describe 'with a matching datetime String without time zone' do
        include_examples 'should match', '1982-07-09T00:00:00'
      end

      describe 'with a matching datetime String in a different time zone' do
        include_examples 'should match',
          -> { "#{other_string}#{offset_string(other_zone)}" }
      end

      describe 'with a matching datetime String in the same time zone' do
        include_examples 'should match',
          -> { "#{time_string}#{offset_string(time_zone)}" }
      end

      describe 'with a non-matching Date' do
        let(:failure_message) { "#{super()}, but the times do not match" }

        include_examples 'should not match', Date.new(2010, 12, 17)
      end

      describe 'with a matching Date' do
        include_examples 'should match', Date.new(1982, 7, 9)
      end

      describe 'with a non-matching DateTime in a different time zone' do
        let(:date_time) do
          DateTime.parse("2010-12-17T00:00:00#{offset_string(other_zone)}")
        end
        let(:failure_message) { "#{super()}, but the times do not match" }

        include_examples 'should not match', -> { date_time }
      end

      describe 'with a non-matching DateTime in the same time zone' do
        let(:date_time) do
          DateTime.parse("2010-12-17T00:00:00#{offset_string(time_zone)}")
        end
        let(:failure_message) { "#{super()}, but the times do not match" }

        include_examples 'should not match', -> { date_time }
      end

      describe 'with a matching DateTime in a different time zone' do
        let(:date_time) do
          DateTime.parse("#{other_string}#{offset_string(other_zone)}")
        end

        include_examples 'should match', -> { date_time }
      end

      describe 'with a matching DateTime in the same time zone' do
        let(:date_time) do
          DateTime.parse("#{time_string}#{offset_string(time_zone)}")
        end

        include_examples 'should match', -> { date_time }
      end

      describe 'with a non-matching Time in a different time zone' do
        let(:time) do
          Time.new(2010, 12, 17, 0, 0, 0, offset_string(other_zone))
        end
        let(:failure_message) { "#{super()}, but the times do not match" }

        include_examples 'should not match', -> { time }
      end

      describe 'with a non-matching Time in the same time zone' do
        let(:time) do
          Time.new(2010, 12, 17, 0, 0, 0, offset_string(time_zone))
        end
        let(:failure_message) { "#{super()}, but the times do not match" }

        include_examples 'should not match', -> { time }
      end

      describe 'with a matching Time in a different time zone' do
        let(:time) do
          Time.new(*other_parts, offset_string(other_zone))
        end

        include_examples 'should match', -> { time }
      end

      describe 'with a matching Time in the same time zone' do
        let(:time) do
          Time.new(*time_parts, offset_string(time_zone))
        end

        include_examples 'should match', -> { time }
      end

      describe 'with a non-matching TimeWithZone in different time zone' do
        let(:time_with_zone) do
          Date.new(2010, 12, 17)
            .in_time_zone('UTC')
            .in_time_zone(other_zone)
        end
        let(:failure_message) { "#{super()}, but the times do not match" }

        include_examples 'should not match', -> { time_with_zone }
      end

      describe 'with a non-matching TimeWithZone in the same time zone' do
        let(:time_with_zone) do
          Date.new(2010, 12, 17)
            .in_time_zone('UTC')
            .in_time_zone(time_zone)
        end
        let(:failure_message) { "#{super()}, but the times do not match" }

        include_examples 'should not match', -> { time_with_zone }
      end

      describe 'with a matching TimeWithZone in different time zone' do
        let(:time_with_zone) do
          Date.new(1982, 7, 9)
            .in_time_zone('UTC')
            .in_time_zone(other_zone)
        end

        include_examples 'should match', -> { time_with_zone }
      end

      describe 'with a matching TimeWithZone in the same time zone' do
        let(:time_with_zone) do
          Date.new(1982, 7, 9)
            .in_time_zone('UTC')
            .in_time_zone(time_zone)
        end

        include_examples 'should match', -> { time_with_zone }
      end
    end

    let(:failure_message) do
      "expected #{actual.inspect} to #{matcher.description}"
    end

    it { expect(matcher).to respond_to(:matches?).with(1).argument }

    context 'when initialized with expected: nil' do
      let(:expected) { nil }
      let(:failure_message) do
        "#{super()}, but the expected value is not a valid time"
      end

      describe 'with an Object' do
        include_examples 'should not match', Object.new.freeze
      end

      describe 'with a Time' do
        include_examples 'should not match', Time.now
      end
    end

    context 'when initialized with expected: an Object' do
      let(:expected) { Object.new.freeze }
      let(:failure_message) do
        "#{super()}, but the expected value is not a valid time"
      end

      describe 'with an Object' do
        include_examples 'should not match', Object.new.freeze
      end

      describe 'with a Time' do
        include_examples 'should not match', Time.now
      end
    end

    context 'when initialized with expected: an invalid String' do
      let(:expected) { '1982-07-32' }
      let(:failure_message) do
        "#{super()}, but the expected value is not a valid time"
      end

      describe 'with an Object' do
        include_examples 'should not match', Object.new.freeze
      end

      describe 'with a Time' do
        include_examples 'should not match', Time.now
      end
    end

    context 'when initialized with expected: an Integer' do
      include_context 'when initialized with a time in UTC'

      let(:expected) do
        Time.new(*time_parts, offset_string(time_zone)).to_i
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a date String' do
      include_context 'when initialized with a time in UTC'

      let(:expected) do
        '1982-07-09'
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a String without time zone' do
      include_context 'when initialized with a time in UTC'

      let(:expected) do
        '1982-07-09T00:00:00'
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a String in UTC' do
      include_context 'when initialized with a time in UTC'

      let(:expected) do
        "#{time_string}#{offset_string(time_zone)}"
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a String outside UTC' do
      include_context 'when initialized with a time outside UTC'

      let(:expected) do
        "#{time_string}#{offset_string(time_zone)}"
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a Date' do
      include_context 'when initialized with a time in UTC'

      let(:expected) do
        Date.new(1982, 7, 9)
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a DateTime in UTC' do
      include_context 'when initialized with a time in UTC'

      let(:expected) do
        DateTime.parse("#{time_string}#{offset_string(time_zone)}")
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a DateTime outside UTC' do
      include_context 'when initialized with a time outside UTC'

      let(:expected) do
        DateTime.parse("#{time_string}#{offset_string(time_zone)}")
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a Time in UTC' do
      include_context 'when initialized with a time in UTC'

      let(:expected) do
        Time.new(*time_parts, offset_string(time_zone))
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a Time outside UTC' do
      include_context 'when initialized with a time outside UTC'

      let(:expected) do
        Time.new(*time_parts, offset_string(time_zone))
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a TimeWithZone in UTC' do
      include_context 'when initialized with a time in UTC'

      let(:expected) do
        Time.new(*time_parts, offset_string(time_zone)).in_time_zone(time_zone)
      end

      include_examples 'should compare the times'
    end

    context 'when initialized with expected: a TimeWithZone outside UTC' do
      include_context 'when initialized with a time outside UTC'

      let(:expected) do
        Time.new(*time_parts, offset_string(time_zone)).in_time_zone(time_zone)
      end

      include_examples 'should compare the times'
    end
  end
  # rubocop:enable Rails/TimeZone
end
