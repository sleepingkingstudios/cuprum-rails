# frozen_string_literal: true

require 'cuprum/rails/actions/new'
require 'cuprum/rails/rspec/actions/new_contracts'

require 'support/book'

RSpec.describe Cuprum::Rails::Actions::New do
  include Cuprum::Rails::RSpec::Actions::NewContracts

  subject(:action) do
    described_class.new(repository: repository, resource: resource)
  end

  let(:repository) { Cuprum::Rails::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(resource_class: Book)
  end

  include_contract 'new action contract'
end
