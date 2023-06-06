# frozen_string_literal: true

require 'cuprum/result'

require 'cuprum/rails/result'
require 'cuprum/rails/rspec/matchers/be_a_result_matcher'

RSpec.describe Cuprum::Rails::RSpec::Matchers::BeAResultMatcher do
  shared_context 'with a class expectation' do
    let(:expected_class) { Cuprum::Rails::Result }
    let(:arguments)      { [expected_class] }
  end

  shared_context 'with an error expectation' do
    let(:expected_error) do
      return super() if defined?(super())

      Cuprum::Error.new(message: 'Something went wrong.')
    end

    before(:example) { fluent_options[:with_error] = expected_error }
  end

  shared_context 'with a metadata expectation' do
    let(:expected_metadata) do
      defined?(super()) ? super() : { session: { token: '12345' } }
    end

    before(:example) { fluent_options[:with_metadata] = expected_metadata }
  end

  shared_context 'with a status expectation' do
    let(:expected_status) { defined?(super()) ? super() : :success }

    before(:example) { fluent_options[:with_status] = expected_status }
  end

  shared_context 'with a value expectation' do
    let(:expected_value) { defined?(super()) ? super() : 'returned value' }

    before(:example) { fluent_options[:with_value] = expected_value }
  end

  shared_context 'with multiple fluent expectations' do
    include_context 'with an error expectation'
    include_context 'with a metadata expectation'
    include_context 'with a status expectation'
    include_context 'with a value expectation'
  end

  subject(:matcher) do
    matcher = described_class.new(*arguments)

    fluent_options.reduce(matcher) do |with_options, (method_name, value)|
      with_options.send(method_name, value)
    end
  end

  let(:expected_class) { Cuprum::Result }
  let(:arguments)      { [] }
  let(:fluent_options) { {} }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end

  describe '#description' do
    let(:expected) { 'be a Cuprum result' }

    it { expect(matcher).to respond_to(:description).with(0).arguments }

    it { expect(matcher.description).to be == expected }

    wrap_context 'with a class expectation' do
      let(:expected) { "be an instance of #{expected_class}" }

      it { expect(matcher.description).to be == expected }
    end

    wrap_context 'with an error expectation' do
      let(:expected) { "#{super()} with the expected error" }

      it { expect(matcher.description).to be == expected }
    end

    wrap_context 'with a metadata expectation' do
      let(:expected) { "#{super()} with the expected metadata" }

      it { expect(matcher.description).to be == expected }
    end

    wrap_context 'with a status expectation' do
      let(:expected) { super() + " with status: #{expected_status.inspect}" }

      it { expect(matcher.description).to be == expected }
    end

    wrap_context 'with a value expectation' do
      let(:expected) { "#{super()} with the expected value" }

      it { expect(matcher.description).to be == expected }
    end

    wrap_context 'with multiple fluent expectations' do
      let(:expected) do
        "#{super()} with the expected error, value, and metadata and status: " \
          "#{expected_status.inspect}"
      end

      it { expect(matcher.description).to be == expected }
    end
  end

  describe '#does_not_match?' do
    shared_examples 'should set the failure message' do
      it 'should set the failure message' do
        matcher.matches?(actual)

        expect(matcher.failure_message_when_negated).to be == failure_message
      end
    end

    let(:description)     { 'be a Cuprum result' }
    let(:failure_message) { "expected #{actual.inspect} not to #{description}" }

    it { expect(matcher).to respond_to(:does_not_match?).with(1).argument }

    describe 'with a Cuprum result' do
      let(:actual) { Cuprum::Result.new }

      it { expect(matcher.does_not_match? actual).to be false }

      include_examples 'should set the failure message'
    end

    describe 'with a result subclass' do
      let(:actual) { Cuprum::Rails::Result.new }

      it { expect(matcher.does_not_match? actual).to be false }

      include_examples 'should set the failure message'
    end

    wrap_context 'with a class expectation' do
      let(:description) { "be an instance of #{expected_class}" }

      describe 'with a Cuprum result' do
        let(:actual) { Cuprum::Result.new }

        it { expect(matcher.does_not_match? actual).to be true }
      end

      describe 'with a result subclass' do
        let(:actual) { Cuprum::Rails::Result.new }

        it { expect(matcher.does_not_match? actual).to be false }

        include_examples 'should set the failure message'
      end
    end

    wrap_context 'with an error expectation' do
      let(:error_message) do
        'Using `expect().not_to be_a_result.with_error()` risks false ' \
          'positives, since any other result will match.'
      end

      it 'should raise an error' do
        expect { matcher.does_not_match? nil }
          .to raise_error ArgumentError, error_message
      end
    end

    wrap_context 'with a metadata expectation' do
      let(:error_message) do
        'Using `expect().not_to be_a_result.with_metadata()` risks false ' \
          'positives, since any other result will match.'
      end

      it 'should raise an error' do
        expect { matcher.does_not_match? nil }
          .to raise_error ArgumentError, error_message
      end
    end

    wrap_context 'with a status expectation' do
      let(:error_message) do
        'Using `expect().not_to be_a_result.with_status()` risks false ' \
          'positives, since any other result will match.'
      end

      it 'should raise an error' do
        expect { matcher.does_not_match? nil }
          .to raise_error ArgumentError, error_message
      end
    end

    wrap_context 'with a value expectation' do
      let(:error_message) do
        'Using `expect().not_to be_a_result.with_value()` risks false ' \
          'positives, since any other result will match.'
      end

      it 'should raise an error' do
        expect { matcher.does_not_match? nil }
          .to raise_error ArgumentError, error_message
      end
    end

    wrap_context 'with multiple fluent expectations' do
      let(:error_message) do
        'Using `expect().not_to be_a_result.with_error().and_status()' \
          '.and_value().and_metadata()` risks false positives, since any ' \
          'other result will match.'
      end

      it 'should raise an error' do
        expect { matcher.does_not_match? nil }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '#expected_class' do
    it { expect(matcher).to respond_to(:expected_class).with(0).arguments }

    it { expect(matcher.expected_class).to be nil }

    wrap_context 'with a class expectation' do
      it { expect(matcher.expected_class).to be expected_class }
    end
  end

  describe '#failure_message' do
    it 'should define the method' do
      expect(matcher).to respond_to(:failure_message).with(0).arguments
    end
  end

  describe '#failure_message_when_negated' do
    it 'should define the method' do
      expect(matcher)
        .to respond_to(:failure_message_when_negated)
        .with(0).arguments
    end
  end

  describe '#matches?' do
    shared_examples 'should set the failure message' do
      it 'should set the failure message' do
        matcher.matches?(actual)

        expect(matcher.failure_message).to be == failure_message
      end
    end

    let(:description)     { 'be a Cuprum result' }
    let(:failure_message) { "expected #{actual.inspect} to #{description}" }

    it { expect(matcher).to respond_to(:matches?).with(1).argument }

    describe 'with nil' do
      let(:actual) { nil }
      let(:failure_message) do
        "#{super()}, but the object is not a result"
      end

      it { expect(matcher.matches? nil).to be false }

      include_examples 'should set the failure message'
    end

    describe 'with an Object' do
      let(:actual) { Object.new.freeze }
      let(:failure_message) do
        "#{super()}, but the object is not a result"
      end

      it { expect(matcher.matches? actual).to be false }

      include_examples 'should set the failure message'
    end

    describe 'with a Cuprum result' do
      let(:actual) { Cuprum::Result.new }

      it { expect(matcher.matches? actual).to be true }
    end

    describe 'with a result subclass' do
      let(:actual) { Cuprum::Rails::Result.new }

      it { expect(matcher.matches? actual).to be true }
    end

    wrap_context 'with a class expectation' do
      let(:description) { "be an instance of #{expected_class}" }

      describe 'with a Cuprum result' do
        let(:actual) { Cuprum::Result.new }
        let(:failure_message) do
          "#{super()}, but the object is not an instance of #{expected_class}"
        end

        it { expect(matcher.matches? actual).to be false }

        include_examples 'should set the failure message'
      end

      describe 'with an instance of the class' do
        let(:actual) { Cuprum::Rails::Result.new }

        it { expect(matcher.matches? actual).to be true }
      end
    end

    wrap_context 'with a status expectation' do
      shared_examples 'should match the result status' do
        describe 'with a non-matching status' do
          let(:params) { { status: :failure } }
          let(:failure_message) do
            super() +
              ', but the status does not match:' \
              "\n  expected status: #{expected_status.inspect}" \
              "\n    actual status: #{params[:status].inspect}"
          end

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        describe 'with a matching status' do
          let(:params) { { status: :success } }

          it { expect(matcher.matches? actual).to be true }
        end
      end

      let(:expected_status) { :success }
      let(:description) do
        super() + " with status: #{expected_status.inspect}"
      end

      describe 'with a Cuprum result' do
        let(:params) { {} }
        let(:actual) { Cuprum::Result.new(**params) }

        include_examples 'should match the result status'
      end

      describe 'with a result subclass' do
        let(:params) { {} }
        let(:actual) { Cuprum::Rails::Result.new(**params) }

        include_examples 'should match the result status'
      end
    end

    describe 'with expected error: nil' do
      include_context 'with an error expectation'

      shared_examples 'should match the result error' do
        describe 'with a non-matching error' do
          let(:params) do
            { error: Cuprum::Error.new(message: 'Other error message.') }
          end
          let(:failure_message) do
            super() +
              ', but the error does not match:' \
              "\n  expected error: #{expected_error.inspect}" \
              "\n    actual error: #{params[:error].inspect}"
          end

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        describe 'with a matching error' do
          let(:params) { { error: nil } }

          it { expect(matcher.matches? actual).to be true }
        end
      end

      let(:expected_error) { nil }
      let(:description)    { "#{super()} with the expected error" }

      describe 'with a Cuprum result' do
        let(:params) { {} }
        let(:actual) { Cuprum::Result.new(**params) }

        include_examples 'should match the result error'
      end

      describe 'with a result subclass' do
        let(:params) { {} }
        let(:actual) { Cuprum::Rails::Result.new(**params) }

        include_examples 'should match the result error'
      end
    end

    describe 'with expected error: value' do
      include_context 'with an error expectation'

      shared_examples 'should match the result error' do
        describe 'with a non-matching error' do
          let(:params) do
            { error: Cuprum::Error.new(message: 'Other error message.') }
          end
          let(:failure_message) do
            super() +
              ', but the error does not match:' \
              "\n  expected error: #{expected_error.inspect}" \
              "\n    actual error: #{params[:error].inspect}"
          end

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        describe 'with a matching error' do
          let(:params) { { error: expected_error } }

          it { expect(matcher.matches? actual).to be true }
        end
      end

      let(:description) { "#{super()} with the expected error" }

      describe 'with a Cuprum result' do
        let(:params) { {} }
        let(:actual) { Cuprum::Result.new(**params) }

        include_examples 'should match the result error'
      end

      describe 'with a result subclass' do
        let(:params) { {} }
        let(:actual) { Cuprum::Rails::Result.new(**params) }

        include_examples 'should match the result error'
      end
    end

    describe 'with expected error: matcher' do
      include_context 'with an error expectation'

      shared_examples 'should match the result error' do
        describe 'with a non-matching error' do
          let(:params) do
            { error: Cuprum::Error.new(message: 'Other error message.') }
          end
          let(:failure_message) do
            super() +
              ', but the error does not match:' \
              "\n  expected error: #{expected_error.description}" \
              "\n    actual error: #{params[:error].inspect}"
          end

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        describe 'with a matching error' do
          let(:params) do
            { error: Spec::CustomError.new(message: 'Something went wrong.') }
          end

          it { expect(matcher.matches? actual).to be true }
        end
      end

      let(:expected_error) { an_instance_of(Spec::CustomError) }
      let(:description) do
        "#{super()} with the expected error"
      end

      example_class 'Spec::CustomError', Cuprum::Error

      describe 'with a Cuprum result' do
        let(:params) { {} }
        let(:actual) { Cuprum::Result.new(**params) }

        include_examples 'should match the result error'
      end

      describe 'with a result subclass' do
        let(:params) { {} }
        let(:actual) { Cuprum::Rails::Result.new(**params) }

        include_examples 'should match the result error'
      end
    end

    describe 'with expected metadata: value' do
      include_context 'with a metadata expectation'

      shared_examples 'should match the result metadata' do
        describe 'with non-matching metadata' do
          let(:params) { { metadata: { secret: '67890' } } }
          let(:failure_message) do
            super() +
              ', but the metadata does not match:' \
              "\n  expected metadata: #{expected_metadata.inspect}" \
              "\n    actual metadata: #{params[:metadata].inspect}"
          end

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        describe 'with matching metadata' do
          let(:params) { { metadata: { session: { token: '12345' } } } }

          it { expect(matcher.matches? actual).to be true }
        end
      end

      let(:description) do
        "#{super()} with the expected metadata"
      end

      describe 'with a Cuprum result' do
        let(:actual) { Cuprum::Result.new }
        let(:failure_message) do
          super() +
            ', but the metadata does not match:' \
            "\n  actual does not respond to #metadata"
        end

        it { expect(matcher.matches? actual).to be false }

        include_examples 'should set the failure message'
      end

      describe 'with a result subclass' do
        let(:params) { {} }
        let(:actual) { Cuprum::Rails::Result.new(**params) }

        include_examples 'should match the result metadata'
      end
    end

    describe 'with expected metadata: matcher' do
      include_context 'with a metadata expectation'

      shared_examples 'should match the result metadata' do
        describe 'with non-matching metadata' do
          let(:params) { { metadata: { secret: '67890' } } }
          let(:failure_message) do
            super() +
              ', but the metadata does not match:' \
              "\n  expected metadata: #{expected_metadata.description}" \
              "\n    actual metadata: #{params[:metadata].inspect}"
          end

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        describe 'with matching metadata' do
          let(:params) { { metadata: { session: { token: '12345' } } } }

          it { expect(matcher.matches? actual).to be true }
        end
      end

      let(:expected_metadata) { satisfy { |actual| actual.key?(:session) } }
      let(:description) do
        "#{super()} with the expected metadata"
      end

      describe 'with a Cuprum result' do
        let(:actual) { Cuprum::Result.new }
        let(:failure_message) do
          super() +
            ', but the metadata does not match:' \
            "\n  actual does not respond to #metadata"
        end

        it { expect(matcher.matches? actual).to be false }

        include_examples 'should set the failure message'
      end

      describe 'with a result subclass' do
        let(:params) { {} }
        let(:actual) { Cuprum::Rails::Result.new(**params) }

        include_examples 'should match the result metadata'
      end
    end

    describe 'with expected value: nil' do
      include_context 'with a value expectation'

      shared_examples 'should match the result value' do
        describe 'with a non-matching value' do
          let(:params) { { value: 'other value' } }
          let(:failure_message) do
            super() +
              ', but the value does not match:' \
              "\n  expected value: #{expected_value.inspect}" \
              "\n    actual value: #{params[:value].inspect}"
          end

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        describe 'with a matching status' do
          let(:params) { { value: nil } }

          it { expect(matcher.matches? actual).to be true }
        end
      end

      let(:expected_value) { nil }
      let(:description) do
        "#{super()} with the expected value"
      end

      describe 'with a Cuprum result' do
        let(:params) { {} }
        let(:actual) { Cuprum::Result.new(**params) }

        include_examples 'should match the result value'
      end

      describe 'with a result subclass' do
        let(:params) { {} }
        let(:actual) { Cuprum::Rails::Result.new(**params) }

        include_examples 'should match the result value'
      end
    end

    describe 'with expected value: value' do
      include_context 'with a value expectation'

      shared_examples 'should match the result value' do
        describe 'with a non-matching value' do
          let(:params) { { value: 'other value' } }
          let(:failure_message) do
            super() +
              ', but the value does not match:' \
              "\n  expected value: #{expected_value.inspect}" \
              "\n    actual value: #{params[:value].inspect}"
          end

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        describe 'with a matching value' do
          let(:params) { { value: 'returned value' } }

          it { expect(matcher.matches? actual).to be true }
        end
      end

      let(:description) do
        "#{super()} with the expected value"
      end

      describe 'with a Cuprum result' do
        let(:params) { {} }
        let(:actual) { Cuprum::Result.new(**params) }

        include_examples 'should match the result value'
      end

      describe 'with a result subclass' do
        let(:params) { {} }
        let(:actual) { Cuprum::Rails::Result.new(**params) }

        include_examples 'should match the result value'
      end
    end

    describe 'with expected value: matcher' do
      include_context 'with a value expectation'

      shared_examples 'should match the result value' do
        describe 'with a non-matching value' do
          let(:params) { { value: :a_symbol } }
          let(:failure_message) do
            super() +
              ', but the value does not match:' \
              "\n  expected value: #{expected_value.description}" \
              "\n    actual value: #{params[:value].inspect}"
          end

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        describe 'with a matching status' do
          let(:params) { { value: 'a string' } }

          it { expect(matcher.matches? actual).to be true }
        end
      end

      let(:expected_value) { an_instance_of(String) }
      let(:description) do
        "#{super()} with the expected value"
      end

      describe 'with a Cuprum result' do
        let(:params) { {} }
        let(:actual) { Cuprum::Result.new(**params) }

        include_examples 'should match the result value'
      end

      describe 'with a result subclass' do
        let(:params) { {} }
        let(:actual) { Cuprum::Rails::Result.new(**params) }

        include_examples 'should match the result value'
      end
    end

    wrap_context 'with multiple fluent expectations' do
      shared_examples 'should match the result properties' do
        describe 'with non-matching properties' do
          let(:params) do
            {
              error:    Cuprum::Error.new(message: 'Other error message.'),
              metadata: { secret: '67890' },
              value:    :a_symbol
            }
          end
          let(:failure_message) do
            super() +
              ', but the error, status, value, and metadata do not match:' \
              "\n     expected error: #{expected_error.inspect}" \
              "\n       actual error: #{actual.error.inspect}" \
              "\n    expected status: #{expected_status.inspect}" \
              "\n      actual status: #{actual.status.inspect}" \
              "\n     expected value: #{expected_value.inspect}" \
              "\n       actual value: #{actual.value.inspect}" \
              "\n  expected metadata: #{expected_metadata.inspect}" \
              "\n    actual metadata: #{actual.metadata.inspect}"
          end

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        describe 'with partially-matching properties' do
          let(:params) do
            {
              error:  expected_error,
              status: expected_status
            }
          end
          let(:failure_message) do
            super() +
              ', but the value and metadata do not match:' \
              "\n     expected value: #{expected_value.inspect}" \
              "\n       actual value: #{actual.value.inspect}" \
              "\n  expected metadata: #{expected_metadata.inspect}" \
              "\n    actual metadata: #{actual.metadata.inspect}"
          end

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        describe 'with matching properties' do
          let(:params) do
            {
              error:    expected_error,
              metadata: expected_metadata,
              status:   expected_status,
              value:    expected_value
            }
          end

          it { expect(matcher.matches? actual).to be true }
        end
      end

      let(:description) do
        super() +
          ' with the expected error, value, and metadata and ' \
          "status: #{expected_status.inspect}"
      end

      describe 'with a Cuprum result' do
        let(:params) { {} }
        let(:actual) { Cuprum::Result.new(**params) }
        let(:failure_message) do
          super() +
            ', but the error, value, and metadata do not match:' \
            "\n     expected error: #{expected_error.inspect}" \
            "\n       actual error: #{params[:error].inspect}" \
            "\n     expected value: #{expected_value.inspect}" \
            "\n       actual value: #{params[:value].inspect}" \
            "\n  actual does not respond to #metadata" \
        end

        it { expect(matcher.matches? actual).to be false }

        include_examples 'should set the failure message'
      end

      describe 'with a result subclass' do
        let(:params) { {} }
        let(:actual) { Cuprum::Rails::Result.new(**params) }

        include_examples 'should match the result properties'
      end
    end
  end

  describe '#with_error' do
    let(:expected_error) { Cuprum::Error.new(message: 'Something went wrong.') }

    it { expect(matcher).to respond_to(:with_error).with(1).argument }

    it { expect(matcher).to have_aliased_method(:with_error).as(:and_error) }

    it { expect(matcher.with_error expected_error).to be matcher }
  end

  describe '#with_metadata' do
    let(:expected_metadata) do
      defined?(super()) ? super() : { session: { token: '12345' } }
    end

    it { expect(matcher).to respond_to(:with_metadata).with(1).argument }

    it 'should alias the method' do
      expect(matcher).to have_aliased_method(:with_metadata).as(:and_metadata)
    end

    it { expect(matcher.with_metadata(expected_metadata)).to be matcher }
  end

  describe '#with_status' do
    it { expect(matcher).to respond_to(:with_status).with(1).argument }

    it { expect(matcher).to have_aliased_method(:with_status).as(:and_status) }

    it { expect(matcher.with_status :success).to be matcher }
  end

  describe '#with_value' do
    it { expect(matcher).to respond_to(:with_value).with(1).argument }

    it { expect(matcher).to have_aliased_method(:with_value).as(:and_value) }

    it { expect(matcher.with_value 'returned value').to be matcher }
  end
end
