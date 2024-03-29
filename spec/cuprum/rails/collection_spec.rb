# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/collection_contracts'
require 'cuprum/collections/rspec/fixtures'

require 'cuprum/rails/collection'
require 'cuprum/rails/commands'

require 'support/book'
require 'support/tome'

RSpec.describe Cuprum::Rails::Collection do
  include Cuprum::Collections::RSpec::Contracts::CollectionContracts

  subject(:collection) { described_class.new(**constructor_options) }

  shared_context 'when the collection has many items' do
    let(:data)  { Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES }
    let(:items) { data.map { |attributes| Book.new(attributes) } }

    before(:each) { items.each(&:save!) }
  end

  let(:name)                { 'books' }
  let(:entity_class)        { Book }
  let(:constructor_options) { { name: name } }
  let(:query_class)         { Cuprum::Rails::Query }
  let(:query_options)       { { record_class: entity_class } }
  let(:default_order)       { { entity_class.primary_key => :asc } }

  example_class 'Grimoire',         Book
  example_class 'Spec::ScopedBook', Book

  include_contract 'should be a collection',
    commands_namespace: 'Cuprum::Rails::Commands'
end
