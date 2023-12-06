# frozen_string_literal: true

require 'cuprum/rails/routing/singular_routes'
require 'cuprum/rails/rspec/contracts/routes_contracts'

require 'support/book'
require 'support/publisher'

RSpec.describe Cuprum::Rails::Routing::SingularRoutes do
  include Cuprum::Rails::RSpec::Contracts::RoutesContracts

  subject(:routes) { described_class.new(base_path: base_path, &block) }

  let(:base_path) { '/book' }
  let(:block)     { nil }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:base_path, :parent_path)
        .and_a_block
    end

    describe 'with a block' do
      let(:block) do
        lambda do
          route :publish,   'publish'
          route :published, 'published'
        end
      end

      include_contract 'should define collection route',
        action_name: :publish,
        path:        '/book/publish'

      include_contract 'should define collection route',
        action_name: :published,
        path:        '/book/published'

      include_contract 'should define collection route',
        action_name: :create,
        path:        '/book'

      include_contract 'should define collection route',
        action_name: :destroy,
        path:        '/book'

      include_contract 'should define collection route',
        action_name: :edit,
        path:        '/book/edit'

      include_contract 'should define collection route',
        action_name: :new,
        path:        '/book/new'

      include_contract 'should define collection route',
        action_name: :show,
        path:        '/book'

      include_contract 'should define collection route',
        action_name: :update,
        path:        '/book'
    end
  end

  include_contract 'should define collection route',
    action_name: :create,
    path:        '/book'

  include_contract 'should define collection route',
    action_name: :destroy,
    path:        '/book'

  include_contract 'should define collection route',
    action_name: :edit,
    path:        '/book/edit'

  include_contract 'should define collection route',
    action_name: :new,
    path:        '/book/new'

  include_contract 'should define collection route',
    action_name: :show,
    path:        '/book'

  include_contract 'should define collection route',
    action_name: :update,
    path:        '/book'

  context 'when initialized with base_path: a value' do
    let(:base_path) { '/publishers/:publisher_id/book' }

    include_contract 'should define collection route',
      action_name: :create,
      path:        '/publishers/:publisher_id/book',
      wildcards:   { publisher_id: 0 }

    include_contract 'should define collection route',
      action_name: :destroy,
      path:        '/publishers/:publisher_id/book',
      wildcards:   { publisher_id: 0 }

    include_contract 'should define collection route',
      action_name: :edit,
      path:        '/publishers/:publisher_id/book/edit',
      wildcards:   { publisher_id: 0 }

    include_contract 'should define collection route',
      action_name: :new,
      path:        '/publishers/:publisher_id/book/new',
      wildcards:   { publisher_id: 0 }

    include_contract 'should define collection route',
      action_name: :show,
      path:        '/publishers/:publisher_id/book',
      wildcards:   { publisher_id: 0 }

    include_contract 'should define collection route',
      action_name: :update,
      path:        '/publishers/:publisher_id/book',
      wildcards:   { publisher_id: 0 }
  end
end
