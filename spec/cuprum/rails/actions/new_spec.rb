# frozen_string_literal: true

require 'cuprum/rails/actions/new'
require 'cuprum/rails/rspec/contracts/actions/new_contracts'

require 'support/book'

RSpec.describe Cuprum::Rails::Actions::New do
  include Cuprum::Rails::RSpec::Contracts::Actions::NewContracts

  subject(:action) { described_class.new }

  let(:repository) do
    Cuprum::Rails::Records::Repository.new.tap do |repository|
      repository.create(entity_class: Book)
    end
  end
  let(:resource) do
    Cuprum::Rails::Resource.new(entity_class: Book)
  end

  include_contract 'should be a new action'
end
