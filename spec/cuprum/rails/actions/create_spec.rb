# frozen_string_literal: true

require 'stannum/errors'

require 'cuprum/rails/actions/create'
require 'cuprum/rails/rspec/actions/create_contracts'

require 'support/book'
require 'support/tome'

RSpec.describe Cuprum::Rails::Actions::Create do
  include Cuprum::Rails::RSpec::Actions::CreateContracts

  subject(:action) { described_class.new }

  let(:repository) { Cuprum::Rails::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(
      entity_class:         Book,
      permitted_attributes: %i[title author series]
    )
  end

  include_contract 'create action contract',
    invalid_attributes: { 'title' => 'Gideon the Ninth' },
    valid_attributes:   {
      'title'  => 'Gideon the Ninth',
      'author' => 'Tamsyn Muir',
      'series' => 'The Locked Tomb'
    }

  context 'with a record class with UUID primary key' do
    let(:resource) do
      Cuprum::Rails::Resource.new(
        entity_class:         Tome,
        permitted_attributes: %i[uuid title author series]
      )
    end

    include_contract 'create action contract',
      duplicate_attributes: {
        'uuid'   => SecureRandom.uuid,
        'title'  => 'Princess Floralinda and the Forty Flight Tower',
        'author' => 'Tamsyn Muir',
        'series' => nil
      },
      invalid_attributes:   { 'title' => 'Gideon the Ninth' },
      valid_attributes:     {
        'uuid'   => SecureRandom.uuid,
        'title'  => 'Gideon the Ninth',
        'author' => 'Tamsyn Muir',
        'series' => 'The Locked Tomb'
      }
  end
end
