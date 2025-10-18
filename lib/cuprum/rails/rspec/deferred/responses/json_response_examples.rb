# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/rails/rspec/deferred/responses'

module Cuprum::Rails::RSpec::Deferred::Responses
  # Deferred examples for validating JSON responses.
  module JsonResponseExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    # Asserts that the response returns the given JSON body.
    #
    # @param data [Object] the serializable object returned in the response.
    # @param status [Integer] the HTTP status for the response. Defaults to 200
    #   OK.
    #
    # The following methods must be defined in the example group:
    #
    # - #response: The response being tested.
    deferred_examples 'should render JSON' \
    do |data:, status: 200|
      include RSpec::SleepingKingStudios::Deferred::Dependencies

      depends_on :response, 'the response being tested'

      let(:configured_data) do
        next data unless data.is_a?(Proc)

        instance_exec(&data)
      end

      it { expect(response).to be_a Cuprum::Rails::Responses::JsonResponse }

      it { expect(response.data).to match(configured_data) }

      it { expect(response.status).to match(status) }
    end
  end
end
