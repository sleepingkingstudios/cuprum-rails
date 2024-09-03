# frozen_string_literal: true

require 'cuprum/rails/routing/plural_routes'
require 'cuprum/rails/rspec/contracts/routes_contracts'

require 'support/book'
require 'support/publisher'

RSpec.describe Cuprum::Rails::Routing::PluralRoutes do
  include Cuprum::Rails::RSpec::Contracts::RoutesContracts

  subject(:routes) { described_class.new(base_path:, &block) }

  let(:base_path) { '/books' }
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
          route :published, 'published'
          route :publish,   ':id/publish'
        end
      end

      include_contract 'should define member route',
        action_name: :publish,
        path:        '/books/:id/publish',
        wildcards:   { id: 0 }

      include_contract 'should define collection route',
        action_name: :published,
        path:        '/books/published'

      include_contract 'should define collection route',
        action_name: :create,
        path:        '/books'

      include_contract 'should define member route',
        action_name: :destroy,
        path:        '/books/:id',
        wildcards:   { id: 0 }

      include_contract 'should define member route',
        action_name: :edit,
        path:        '/books/:id/edit',
        wildcards:   { id: 0 }

      include_contract 'should define collection route',
        action_name: :index,
        path:        '/books'

      include_contract 'should define collection route',
        action_name: :new,
        path:        '/books/new'

      include_contract 'should define member route',
        action_name: :show,
        path:        '/books/:id',
        wildcards:   { id: 0 }

      include_contract 'should define member route',
        action_name: :update,
        path:        '/books/:id',
        wildcards:   { id: 0 }
    end
  end

  include_contract 'should define collection route',
    action_name: :create,
    path:        '/books'

  include_contract 'should define member route',
    action_name: :destroy,
    path:        '/books/:id',
    wildcards:   { id: 0 }

  include_contract 'should define member route',
    action_name: :edit,
    path:        '/books/:id/edit',
    wildcards:   { id: 0 }

  include_contract 'should define collection route',
    action_name: :index,
    path:        '/books'

  include_contract 'should define collection route',
    action_name: :new,
    path:        '/books/new'

  include_contract 'should define member route',
    action_name: :show,
    path:        '/books/:id',
    wildcards:   { id: 0 }

  include_contract 'should define member route',
    action_name: :update,
    path:        '/books/:id',
    wildcards:   { id: 0 }

  context 'when initialized with base_path: a value' do
    let(:base_path) { '/publishers/:publisher_id/books' }

    include_contract 'should define collection route',
      action_name: :create,
      path:        '/publishers/:publisher_id/books',
      wildcards:   { publisher_id: 0 }

    include_contract 'should define member route',
      action_name: :destroy,
      path:        '/publishers/:publisher_id/books/:id',
      wildcards:   { publisher_id: 0, id: 1 }

    include_contract 'should define member route',
      action_name: :edit,
      path:        '/publishers/:publisher_id/books/:id/edit',
      wildcards:   { publisher_id: 0, id: 1 }

    include_contract 'should define collection route',
      action_name: :index,
      path:        '/publishers/:publisher_id/books',
      wildcards:   { publisher_id: 0 }

    include_contract 'should define collection route',
      action_name: :new,
      path:        '/publishers/:publisher_id/books/new',
      wildcards:   { publisher_id: 0 }

    include_contract 'should define member route',
      action_name: :show,
      path:        '/publishers/:publisher_id/books/:id',
      wildcards:   { publisher_id: 0, id: 1 }

    include_contract 'should define member route',
      action_name: :update,
      path:        '/publishers/:publisher_id/books/:id',
      wildcards:   { publisher_id: 0, id: 1 }
  end
end
