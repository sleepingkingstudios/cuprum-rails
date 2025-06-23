# frozen_string_literal: true

require 'cuprum/rails/rspec/matchers'

require 'support/book'

RSpec.describe Cuprum::Rails::RSpec::Matchers do
  include described_class

  let(:example_group) { self }

  describe '#be_a_failing_result' do
    let(:matcher_class) { Cuprum::Rails::RSpec::Matchers::BeAResultMatcher }
    let(:matcher)       { example_group.be_a_failing_result }

    it 'should define the method' do
      expect(example_group)
        .to respond_to(:be_a_failing_result)
        .with(0..1).arguments
    end

    it { expect(matcher).to be_a matcher_class }

    it { expect(matcher.expected_class).to be nil }

    it 'should set the description' do
      expect(matcher.description)
        .to be == 'be a Cuprum result with status: :failure'
    end

    describe 'with a result subclass' do
      let(:expected_class) { Cuprum::Rails::Result }
      let(:matcher)        { example_group.be_a_failing_result(expected_class) }

      it 'should set the description' do
        expect(matcher.description)
          .to be == "be an instance of #{expected_class} with status: :failure"
      end

      it { expect(matcher.expected_class).to be expected_class }
    end
  end

  describe '#be_a_passing_result' do
    let(:matcher_class) { Cuprum::Rails::RSpec::Matchers::BeAResultMatcher }
    let(:matcher)       { example_group.be_a_passing_result }
    let(:expectations) do
      'with the expected error and status: :success'
    end

    it 'should define the method' do
      expect(example_group)
        .to respond_to(:be_a_passing_result)
        .with(0..1).arguments
    end

    it { expect(matcher).to be_a matcher_class }

    it { expect(matcher.expected_class).to be nil }

    it 'should set the description' do
      expect(matcher.description)
        .to be == "be a Cuprum result #{expectations}"
    end

    describe 'with a result subclass' do
      let(:expected_class) { Cuprum::Rails::Result }
      let(:matcher)        { example_group.be_a_passing_result(expected_class) }

      it 'should set the description' do
        expect(matcher.description)
          .to be == "be an instance of #{expected_class} #{expectations}"
      end

      it { expect(matcher.expected_class).to be expected_class }
    end
  end

  describe '#be_a_record' do
    let(:matcher_class) { Cuprum::Rails::RSpec::Matchers::BeARecordMatcher }
    let(:matcher)       { example_group.be_a_record(record_class) }
    let(:record_class)  { Book }

    it 'should define the method' do
      expect(example_group).to respond_to(:be_a_record).with(1).argument
    end

    it { expect(matcher).to be_a matcher_class }

    it { expect(matcher.description).to be == 'be a Book' }

    it { expect(matcher.record_class).to be Book }
  end

  describe '#be_a_result' do
    let(:matcher_class) { Cuprum::Rails::RSpec::Matchers::BeAResultMatcher }
    let(:matcher)       { example_group.be_a_result }

    it 'should define the method' do
      expect(example_group).to respond_to(:be_a_result).with(0..1).arguments
    end

    it { expect(matcher).to be_a matcher_class }

    it { expect(matcher.description).to be == 'be a Cuprum result' }

    it { expect(matcher.expected_class).to be nil }

    describe 'with a result subclass' do
      let(:expected_class) { Cuprum::Rails::Result }
      let(:matcher)        { example_group.be_a_result(expected_class) }

      it 'should set the description' do
        expect(matcher.description)
          .to be == "be an instance of #{expected_class}"
      end

      it { expect(matcher.expected_class).to be expected_class }
    end
  end

  describe '#match_time' do
    let(:matcher_class) { Cuprum::Rails::RSpec::Matchers::MatchTimeMatcher }
    let(:matcher)       { example_group.match_time(expected) }
    let(:expected)      { Time.zone.today }

    it 'should define the method' do
      expect(example_group).to respond_to(:match_time).with(1).argument
    end

    it { expect(matcher).to be_a matcher_class }

    it { expect(matcher.description).to be == "match time #{expected.inspect}" }

    it { expect(matcher.expected).to be expected }
  end
end
