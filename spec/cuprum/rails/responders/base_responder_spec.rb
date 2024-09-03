# frozen_string_literal: true

require 'cuprum/rails/responders/base_responder'
require 'cuprum/rails/rspec/contracts/responder_contracts'

RSpec.describe Cuprum::Rails::Responders::BaseResponder do
  include Cuprum::Rails::RSpec::Contracts::ResponderContracts

  subject(:responder) { described_class.new(**constructor_options) }

  let(:action_name) { :published }
  let(:controller)  { Spec::CustomController.new }
  let(:request)     { Cuprum::Rails::Request.new }
  let(:constructor_options) do
    {
      action_name:,
      controller:,
      request:
    }
  end

  include_contract 'should implement the responder methods'
end
