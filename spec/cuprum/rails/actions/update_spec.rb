# frozen_string_literal: true

require 'stannum/errors'

require 'cuprum/rails/actions/update'
require 'cuprum/rails/rspec/contracts/actions/update_contracts'

require 'support/book'
require 'support/tome'

RSpec.describe Cuprum::Rails::Actions::Update do
  include Cuprum::Rails::RSpec::Contracts::Actions::UpdateContracts

  subject(:action) { described_class.new }

  let(:repository) { Cuprum::Rails::Records::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(
      entity_class:         Book,
      permitted_attributes: %i[title author series]
    )
  end
  let(:entity) do
    Book.new(
      'title'  => 'Gideon the Ninth',
      'author' => 'Tamsyn Muir',
      'series' => 'The Locked Tomb'
    )
  end
  let(:invalid_attributes) do
    { 'author' => '' }
  end
  let(:valid_attributes) do
    {
      'title'  => 'Princess Floralinda and the Forty Flight Tower',
      'series' => nil
    }
  end

  before(:example) { entity.save! }

  include_contract 'should be an update action',
    existing_entity:    -> { entity },
    invalid_attributes: -> { invalid_attributes },
    valid_attributes:   -> { valid_attributes }

  context 'with a record class with UUID primary key' do
    let(:resource) do
      Cuprum::Rails::Resource.new(
        entity_class:         Tome,
        permitted_attributes: %i[uuid title author series]
      )
    end
    let(:entity) do
      Tome.new(
        'uuid'   => SecureRandom.uuid,
        'title'  => 'Gideon the Ninth',
        'author' => 'Tamsyn Muir',
        'series' => 'The Locked Tomb'
      )
    end

    include_contract 'should be an update action',
      existing_entity:    -> { entity },
      primary_key_value:  -> { SecureRandom.uuid },
      invalid_attributes: -> { invalid_attributes },
      valid_attributes:   -> { valid_attributes }
  end
end
