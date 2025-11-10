# frozen_string_literal: true

require 'cuprum/rails/actions/edit'
require 'cuprum/rails/rspec/contracts/actions/edit_contracts'

require 'support/book'
require 'support/tome'

RSpec.describe Cuprum::Rails::Actions::Edit do
  include Cuprum::Rails::RSpec::Contracts::Actions::EditContracts

  subject(:action) { described_class.new }

  let(:repository) do
    Cuprum::Rails::Records::Repository.new.tap do |repository|
      repository.create(entity_class: Book)
      repository.create(entity_class: Tome)
    end
  end
  let(:resource) do
    Cuprum::Rails::Resource.new(entity_class: Book)
  end
  let(:entity) do
    Book.new(
      'title'  => 'Gideon the Ninth',
      'author' => 'Tamsyn Muir',
      'series' => 'The Locked Tomb'
    )
  end

  before(:example) { entity.save! }

  include_contract 'should be an edit action',
    existing_entity: -> { entity }

  context 'with a record class with UUID primary key' do
    let(:resource) do
      Cuprum::Rails::Resource.new(entity_class: Tome)
    end
    let(:entity) do
      Tome.new(
        'uuid'   => SecureRandom.uuid,
        'title'  => 'Gideon the Ninth',
        'author' => 'Tamsyn Muir',
        'series' => 'The Locked Tomb'
      )
    end

    include_contract 'should be an edit action',
      existing_entity:   -> { entity },
      primary_key_value: -> { SecureRandom.uuid }
  end
end
