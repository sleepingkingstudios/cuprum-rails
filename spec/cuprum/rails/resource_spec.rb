# frozen_string_literal: true

require 'cuprum/rails/resource'
require 'cuprum/rails/rspec/deferred/resource_examples'

require 'support/book'

RSpec.describe Cuprum::Rails::Resource do
  include Cuprum::Rails::RSpec::Deferred::ResourceExamples

  subject(:resource) { described_class.new(**constructor_options) }

  let(:name)                { 'books' }
  let(:constructor_options) { { name: } }

  describe '::PLURAL_ACTIONS' do
    let(:expected) { %w[create destroy edit index new show update] }

    include_examples 'should define immutable constant',
      :PLURAL_ACTIONS,
      -> { expected }
  end

  describe '::SINGULAR_ACTIONS' do
    let(:expected) { %w[create destroy edit new show update] }

    include_examples 'should define immutable constant',
      :SINGULAR_ACTIONS,
      -> { expected }
  end

  include_deferred 'should be a Rails Resource'
end
