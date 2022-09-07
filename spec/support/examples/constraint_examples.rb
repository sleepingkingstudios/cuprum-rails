# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'
require 'stannum/rspec/match_errors'

require 'support/examples'

module Spec::Support::Examples
  module ConstraintExamples
    extend  RSpec::SleepingKingStudios::Concerns::SharedExampleGroup
    include Stannum::RSpec::Matchers

    shared_examples 'should match the constraint' do
      let(:actual_status) do
        status, _ = subject.send(match_method, actual)

        status
      end
      let(:actual_errors) do
        _, errors = subject.send(match_method, actual)

        errors
      end

      it { expect(actual_status).to be true }

      it { expect(actual_errors).to match_errors(Stannum::Errors.new) }
    end

    shared_examples 'should not match the constraint' do
      let(:actual_status) do
        status, _ = subject.send(match_method, actual)

        status
      end
      let(:actual_errors) do
        _, errors = subject.send(match_method, actual)

        errors
      end
      let(:wrapped_errors) do
        errors =
          if expected_errors.is_a?(Array)
            expected_errors
          else
            [expected_errors]
          end

        errors
          .map do |error|
            {
              data:    {},
              message: nil,
              path:    []
            }.merge(error)
          end
      end
      let(:wrapped_messages) do
        # :nocov:
        errors =
          if expected_messages.is_a?(Array)
            expected_messages
          else
            [expected_messages]
          end
        # :nocov:

        errors
          .map do |error|
            {
              data:    {},
              message: nil,
              path:    []
            }.merge(error)
          end
      end

      it { expect(actual_status).to be false }

      it { expect(actual_errors).to match_errors wrapped_errors }

      if instance_methods.include?(:expected_messages)
        it 'should generate the error messages' do
          expect(actual_errors.with_messages).to match_errors wrapped_messages
        end
      end
    end
  end
end
