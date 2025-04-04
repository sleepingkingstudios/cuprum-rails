# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'cuprum/rails/records/repository'
require 'cuprum/rails/resource'

require 'support/book'
require 'support/examples/commands'

module Spec::Support::Examples::Commands
  module BooksExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_context 'with parameters for a Book command' do
      let(:repository) { Cuprum::Collections::Basic::Repository.new }
      let(:resource) do
        Cuprum::Rails::Resource.new(name: 'books', **resource_options)
      end
      let(:resource_options) do
        {
          default_order:        'id',
          permitted_attributes: %w[title author series category],
          primary_key_name:     'id'
        }
      end
      let(:default_contract) do
        Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
          key 'author', Stannum::Constraints::Presence.new
          key 'title',  Stannum::Constraints::Presence.new
        end
      end
      let(:fixtures_data) do
        Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
      end

      ##########################################################################
      ###                         Querying Parameters                        ###
      ##########################################################################

      let(:resource_scope) do
        Cuprum::Collections::Scope.new({ 'series' => nil })
      end
      let(:non_matching_scope) do
        Cuprum::Collections::Scope.new do |query|
          { 'published_at' => query.gte('2070-01-01') }
        end
      end
      let(:unique_scope) do
        Cuprum::Collections::Scope.new do |query|
          {
            'author'       => 'J.R.R. Tolkien',
            'published_at' => query.gte('1970-01-01')
          }
        end
      end
      let(:order)      { { 'title' => 'asc' } }
      let(:where_hash) { { 'author' => 'Ursula K. LeGuin' } }

      ##########################################################################
      ###                         Resource Parameters                        ###
      ##########################################################################

      let(:extra_attributes) do
        {
          'published_at' => '2019-09-10'
        }
      end
      let(:invalid_attributes) do
        {
          'title'  => 'Gideon the Ninth',
          'author' => nil
        }
      end
      let(:valid_attributes) do
        {
          'title'  => 'Gideon the Ninth',
          'author' => 'Tamsyn Muir'
        }
      end
    end
  end
end
