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

  describe '#be_a_timestamp' do
    let(:matcher) { example_group.be_a_timestamp }

    it 'should define the method' do
      expect(example_group)
        .to respond_to(:be_a_timestamp)
        .with(0).arguments
        .and_keywords(:optional)
    end

    it 'should alias the method' do
      expect(example_group)
        .to have_aliased_method(:be_a_timestamp)
        .as(:a_timestamp)
    end

    describe 'when matching nil' do
      it { expect(matcher.matches?(nil)).to be false }
    end

    describe 'when matching an Object' do
      it { expect(matcher.matches?(Object.new.freeze)).to be false }
    end

    describe 'when matching a timestamp' do
      it { expect(matcher.matches?(Time.zone.now)).to be true }
    end

    describe 'with optional: true' do
      let(:matcher) { example_group.be_a_timestamp(optional: true) }

      describe 'when matching nil' do
        it { expect(matcher.matches?(nil)).to be true }
      end

      describe 'when matching an Object' do
        it { expect(matcher.matches?(Object.new.freeze)).to be false }
      end

      describe 'when matching a timestamp' do
        it { expect(matcher.matches?(Time.zone.now)).to be true }
      end
    end
  end

  describe '#match_record' do
    let(:attributes)   { {} }
    let(:record_class) { Book }
    let(:matcher) do
      example_group.match_record(attributes:, record_class:)
    end

    it 'should define the method' do
      expect(example_group)
        .to respond_to(:match_record)
        .with(0).arguments
        .and_keywords(:attributes, :record_class)
    end

    describe 'with attributes: nil' do
      let(:attributes) { nil }

      describe 'when matching nil' do
        it { expect(matcher.matches?(nil)).to be true }
      end

      describe 'when matching a record' do
        let(:record) { record_class.new }

        it { expect(matcher.matches?(record)).to be false }
      end
    end

    describe 'with attributes: an empty Hash' do
      let(:attributes) { {} }

      describe 'when matching nil' do
        it { expect(matcher.matches?(nil)).to be false }
      end

      describe 'when matching a record with matching attributes' do
        let(:record) { record_class.new(attributes) }

        it { expect(matcher.matches?(record)).to be true }
      end

      describe 'when matching a record with extra attributes' do
        let(:record) do
          record_class.new(attributes.merge(series: 'The Locked Tomb'))
        end

        it { expect(matcher.matches?(record)).to be true }
      end
    end

    describe 'with attributes: a non-empty Hash' do
      let(:attributes) { { title: 'Gideon the Ninth', author: 'Tammsyn Muir' } }

      describe 'when matching nil' do
        it { expect(matcher.matches?(nil)).to be false }
      end

      describe 'when matching a record with non-matching attributes' do
        let(:record) do
          record_class.new(attributes.merge(title: 'Harrow the Ninth'))
        end

        it { expect(matcher.matches?(record)).to be false }
      end

      describe 'when matching a record with matching attributes' do
        let(:record) { record_class.new(attributes) }

        it { expect(matcher.matches?(record)).to be true }
      end

      describe 'when matching a record with extra attributes' do
        let(:record) do
          record_class.new(attributes.merge(series: 'The Locked Tomb'))
        end

        it { expect(matcher.matches?(record)).to be true }
      end
    end
  end
end
