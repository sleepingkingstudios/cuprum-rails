# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/scopes/conjunction_examples'

require 'cuprum/rails/records/scopes/conjunction_scope'
require 'cuprum/rails/records/scopes/criteria_scope'
require 'cuprum/rails/rspec/deferred/scope_examples'

RSpec.describe Cuprum::Rails::Records::Scopes::ConjunctionScope do
  include Cuprum::Collections::RSpec::Deferred::Scopes::ConjunctionExamples
  include Cuprum::Rails::RSpec::Deferred::ScopeExamples

  subject(:scope) { described_class.new(scopes:) }

  let(:scopes)       { [] }
  let(:native_query) { Book.all }
  let(:data)         { [] }

  define_method :build_scope do |filters = nil, &block|
    scope_class = Cuprum::Rails::Records::Scopes::CriteriaScope

    if block
      scope_class.build(&block)
    else
      scope_class.build(filters)
    end
  end

  define_method :filtered_data do
    scope
      .call(native_query:)
      .map do |record|
        record
          .attributes
          .merge('published_at' => record.published_at.strftime('%Y-%m-%d'))
      end
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:scopes)
        .and_any_keywords
    end
  end

  include_deferred 'should implement the ConjunctionScope methods'

  include_deferred 'should implement the Records::Scope methods'

  describe '#build_relation' do
    let(:record_class) { Book }

    define_method :filtered_data do
      scope
        .build_relation(record_class:)
        .map do |record|
          record
            .attributes
            .merge('published_at' => record.published_at.strftime('%Y-%m-%d'))
        end
    end

    include_deferred 'should filter data by logical AND'
  end
end
