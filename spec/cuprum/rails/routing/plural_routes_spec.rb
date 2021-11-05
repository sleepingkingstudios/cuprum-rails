# frozen_string_literal: true

require 'cuprum/rails/routing/plural_routes'
require 'cuprum/rails/rspec/define_route_contract'

require 'support/book'
require 'support/publisher'

RSpec.describe Cuprum::Rails::Routing::PluralRoutes do
  subject(:routes) { described_class.new(base_path: base_path, &block) }

  let(:base_path) { '/books' }
  let(:block)     { nil }
  let(:entity) do
    Book.create!(
      author: 'Tamsyn Muir',
      title:  'Gideon the Ninth'
    )
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:base_path)
        .and_a_block
    end

    describe 'with a block' do
      let(:block) do
        lambda do
          route :published, 'published'
          route :publish,   ':id/publish'
        end
      end
      let(:entity) do
        Book.create!(
          author: 'Tamsyn Muir',
          title:  'Gideon the Ninth'
        )
      end

      include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
        action_name:   :publish,
        member_action: true,
        path:          '/books/:id/publish'

      include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
        action_name: :published,
        path:        '/books/published'

      include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
        action_name: :create,
        path:        '/books'

      include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
        action_name:   :destroy,
        member_action: true,
        path:          '/books/:id'

      include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
        action_name:   :edit,
        member_action: true,
        path:          '/books/:id/edit'

      include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
        action_name: :index,
        path:        '/books'

      include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
        action_name: :new,
        path:        '/books/new'

      include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
        action_name:   :show,
        member_action: true,
        path:          '/books/:id'

      include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
        action_name:   :update,
        member_action: true,
        path:          '/books/:id'
    end
  end

  include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
    action_name: :create,
    path:        '/books'

  include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
    action_name:   :destroy,
    member_action: true,
    path:          '/books/:id'

  include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
    action_name:   :edit,
    member_action: true,
    path:          '/books/:id/edit'

  include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
    action_name: :index,
    path:        '/books'

  include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
    action_name: :new,
    path:        '/books/new'

  include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
    action_name:   :show,
    member_action: true,
    path:          '/books/:id'

  include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
    action_name:   :update,
    member_action: true,
    path:          '/books/:id'

  context 'when initialized with base_path: a value' do
    let(:base_path) { '/publishers/:publisher_id/books' }

    include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
      action_name: :create,
      path:        '/publishers/0/books',
      wildcards:   { publisher_id: 0 }

    include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
      action_name:   :destroy,
      member_action: true,
      path:          '/publishers/0/books/:id',
      wildcards:     { publisher_id: 0 }

    include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
      action_name:   :edit,
      member_action: true,
      path:          '/publishers/0/books/:id/edit',
      wildcards:     { publisher_id: 0 }

    include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
      action_name: :index,
      path:        '/publishers/0/books',
      wildcards:   { publisher_id: 0 }

    include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
      action_name: :new,
      path:        '/publishers/0/books/new',
      wildcards:   { publisher_id: 0 }

    include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
      action_name:   :show,
      member_action: true,
      path:          '/publishers/0/books/:id',
      wildcards:     { publisher_id: 0 }

    include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
      action_name:   :update,
      member_action: true,
      path:          '/publishers/0/books/:id',
      wildcards:     { publisher_id: 0 }
  end
end
