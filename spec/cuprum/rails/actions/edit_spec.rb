# frozen_string_literal: true

require 'cuprum/rails/actions/edit'
require 'cuprum/rails/rspec/actions/edit_contracts'

require 'support/book'
require 'support/tome'

RSpec.describe Cuprum::Rails::Actions::Edit do
  include Cuprum::Rails::RSpec::Actions::EditContracts

  subject(:action) { described_class.new }

  let(:repository) { Cuprum::Rails::Repository.new }
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

  include_contract 'edit action contract',
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

    include_contract 'edit action contract',
      existing_entity:   -> { entity },
      primary_key_value: -> { SecureRandom.uuid }
  end
end
