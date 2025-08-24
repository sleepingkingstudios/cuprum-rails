# frozen_string_literal: true

require 'cuprum/rails/responders/base_responder'
require 'cuprum/rails/rspec/deferred/responder_examples'

RSpec.describe Cuprum::Rails::Responders::BaseResponder do
  include Cuprum::Rails::RSpec::Deferred::ResponderExamples

  subject(:responder) { described_class.new(**constructor_options) }

  let(:constructor_options) do
    {
      action_name:,
      controller:,
      request:
    }
  end

  include_deferred 'should implement the Responder methods'
end
