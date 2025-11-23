# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/scopes/all_examples'

require 'cuprum/rails/records/scopes/all_scope'
require 'cuprum/rails/rspec/deferred/scope_examples'

RSpec.describe Cuprum::Rails::Records::Scopes::AllScope do
  include Cuprum::Collections::RSpec::Deferred::Scopes::AllExamples
  include Cuprum::Rails::RSpec::Deferred::ScopeExamples

  subject(:scope) { described_class.new }

  let(:native_query) { Book.all }
  let(:data)         { [] }

  define_method :filtered_data do
    subject
      .call(native_query:)
      .map do |record|
        record
          .attributes
          .merge('published_at' => record.published_at.strftime('%Y-%m-%d'))
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

  include_deferred 'should implement the AllScope methods'

  include_deferred 'should implement the Records::Scope methods'
end
