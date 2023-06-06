# frozen_string_literal: true

require 'cuprum/rails/rspec/matchers'

RSpec.describe Cuprum::Rails::RSpec::Matchers do
  include described_class

  let(:example_group) { self }
  let(:matcher_class) do
    Cuprum::Rails::RSpec::Matchers::BeAResultMatcher
  end

  describe '#be_a_failing_result' do
    let(:matcher) { example_group.be_a_failing_result }

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
    let(:matcher) { example_group.be_a_passing_result }
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
    let(:matcher) { example_group.be_a_result }

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
end
