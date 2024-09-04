# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/scope_contracts'

require 'cuprum/rails/records/scopes/none_scope'
require 'cuprum/rails/rspec/contracts/scope_contracts'

RSpec.describe Cuprum::Rails::Records::Scopes::NoneScope do
  include Cuprum::Collections::RSpec::Contracts::ScopeContracts
  include Cuprum::Rails::RSpec::Contracts::ScopeContracts

  subject(:scope) { described_class.new }

  let(:native_query) { Book.all }
  let(:data)         { [] }

  def filtered_data
    subject
      .call(native_query:)
      .map do |record|
        # :nocov:
        record
          .attributes
          .merge('published_at' => record.published_at.strftime('%Y-%m-%d'))
        # :nocov:
      end
  end

  describe '.instance' do
    let(:expected) { described_class.instance }

    include_examples 'should define class reader', :instance

    it { expect(described_class.instance).to be_a described_class }

    it { expect(described_class.instance).to be expected }
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_any_keywords
    end
  end

  include_contract 'should be a none scope'

  include_contract 'should be a rails scope'
end
