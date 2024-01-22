# frozen_string_literal: true

require 'cuprum/collections/rspec/fixtures'

require 'cuprum/rails/actions/index'
require 'cuprum/rails/rspec/contracts/actions/index_contracts'

require 'support/book'
require 'support/tome'

RSpec.xdescribe Cuprum::Rails::Actions::Index do
  include Cuprum::Rails::RSpec::Contracts::Actions::IndexContracts

  subject(:action) { described_class.new }

  shared_context 'with a request with parameters' do
    let(:params)  { {} }
    let(:request) { instance_double(Cuprum::Rails::Request, params: params) }

    before(:example) do
      allow(action).to receive(:request).and_return(request) # rubocop:disable RSpec/SubjectStub
    end
  end

  let(:repository) { Cuprum::Rails::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(
      entity_class: Book,
      **resource_options
    )
  end
  let(:resource_options) { {} }

  # rubocop:disable Style/RedundantLineContinuation
  include_contract 'should be an index action',
    existing_entities: [] \
  do
    context 'when there are many entities' do
      let(:resource_options) { super().merge(default_order: :id) }
      let(:entities) do
        [
          Book.new(
            'title'  => 'Gideon the Ninth',
            'author' => 'Tamsyn Muir',
            'series' => 'The Locked Tomb'
          ),
          Book.new(
            'title'  => 'Harrow the Ninth',
            'author' => 'Tamsyn Muir',
            'series' => 'The Locked Tomb'
          ),
          Book.new(
            'title'  => 'Nona the Ninth',
            'author' => 'Tamsyn Muir',
            'series' => 'The Locked Tomb'
          ),
          Book.new(
            'title'  => 'Alecto the Ninth',
            'author' => 'Tamsyn Muir',
            'series' => 'The Locked Tomb'
          ),
          Book.new(
            'title'  => 'Princess Floralinda and the Forty Flight Tower',
            'author' => 'Tamsyn Muir',
            'series' => nil
          )
        ]
      end

      before(:example) { entities.map(&:save!) }

      include_contract 'should find the entities',
        existing_entities: -> { entities.sort_by(&:id) }

      describe 'with a filter' do
        let(:matching_entities) do
          entities.select { |entity| entity.series == 'The Locked Tomb' }
        end

        include_contract 'should find the entities',
          existing_entities: -> { matching_entities.sort_by(&:id) },
          params:            { 'where' => { 'series' => 'The Locked Tomb' } }
      end

      describe 'with an ordering' do
        include_contract 'should find the entities',
          existing_entities: -> { entities.sort_by(&:title) },
          params:            { 'order' => 'title' }
      end
    end
  end
  # rubocop:enable Style/RedundantLineContinuation

  describe '#default_order' do
    include_examples 'should define reader', :default_order

    context 'when called with a resource' do
      before(:example) { call_action }

      it { expect(action.default_order).to be == {} }

      context 'when the resource has a default order' do
        let(:default_order) { { author: :asc, title: :asc } }
        let(:resource_options) do
          super().merge(default_order: default_order)
        end

        it { expect(action.default_order).to be == default_order }
      end
    end
  end

  describe '#filter_params' do
    include_context 'with a request with parameters'

    include_examples 'should define private reader', :filter_params, -> { {} }

    context 'when the request has filter parameters' do
      let(:params) do
        {
          'limit'  => 3,
          'offset' => 2,
          'order'  => %w[author title],
          'where'  => { 'series' => nil }
        }
      end
      let(:expected) { tools.hash_tools.convert_keys_to_strings(params) }

      def tools
        SleepingKingStudios::Tools::Toolbelt.instance
      end

      it { expect(action.send :filter_params).to be == expected }
    end
  end

  describe '#limit' do
    include_context 'with a request with parameters'

    include_examples 'should define private reader', :limit, nil

    context 'when the request has filter parameters' do
      let(:params) do
        {
          'limit'  => 3,
          'offset' => 2,
          'order'  => %w[author title],
          'where'  => { 'series' => nil }
        }
      end

      it { expect(action.send :limit).to be == params['limit'] }
    end
  end

  describe '#offset' do
    include_context 'with a request with parameters'

    include_examples 'should define private reader', :offset, nil

    context 'when the request has filter parameters' do
      let(:params) do
        {
          'limit'  => 3,
          'offset' => 2,
          'order'  => %w[author title],
          'where'  => { 'series' => nil }
        }
      end

      it { expect(action.send :offset).to be == params['offset'] }
    end
  end

  describe '#order' do
    include_context 'with a request with parameters'

    include_examples 'should define private reader', :order

    context 'when called with a resource' do
      before(:example) { call_action }

      it { expect(action.send :order).to be nil }

      context 'when the resource has a default order' do
        let(:default_order) { { author: :asc, title: :asc } }
        let(:resource_options) do
          super().merge(default_order: default_order)
        end

        it { expect(action.send :order).to be == default_order }

        context 'when the request has filter parameters' do
          let(:params) do
            {
              'limit'  => 3,
              'offset' => 2,
              'order'  => %w[author title],
              'where'  => { 'series' => nil }
            }
          end

          it { expect(action.send :order).to be == params['order'] }
        end
      end

      context 'when the request has filter parameters' do
        let(:params) do
          {
            'limit'  => 3,
            'offset' => 2,
            'order'  => %w[author title],
            'where'  => { 'series' => nil }
          }
        end

        it { expect(action.send :order).to be == params['order'] }
      end
    end
  end

  describe '#where' do
    include_context 'with a request with parameters'

    include_examples 'should define private reader', :where, nil

    context 'when the request has filter parameters' do
      let(:params) do
        {
          'limit'  => 3,
          'offset' => 2,
          'order'  => %w[author title],
          'where'  => { 'series' => nil }
        }
      end

      it { expect(action.send :where).to be == params['where'] }
    end
  end

  context 'with a record class with UUID primary key' do
    let(:resource) do
      Cuprum::Rails::Resource.new(
        entity_class: Tome,
        **resource_options
      )
    end

    # rubocop:disable Style/RedundantLineContinuation
    include_contract 'should be an index action',
      existing_entities: [] \
    do
      context 'when there are many entities' do
        let(:entities) do
          [
            Tome.new(
              'uuid'   => SecureRandom.uuid,
              'title'  => 'Gideon the Ninth',
              'author' => 'Tamsyn Muir',
              'series' => 'The Locked Tomb'
            ),
            Tome.new(
              'uuid'   => SecureRandom.uuid,
              'title'  => 'Harrow the Ninth',
              'author' => 'Tamsyn Muir',
              'series' => 'The Locked Tomb'
            ),
            Tome.new(
              'uuid'   => SecureRandom.uuid,
              'title'  => 'Nona the Ninth',
              'author' => 'Tamsyn Muir',
              'series' => 'The Locked Tomb'
            ),
            Tome.new(
              'uuid'   => SecureRandom.uuid,
              'title'  => 'Alecto the Ninth',
              'author' => 'Tamsyn Muir',
              'series' => 'The Locked Tomb'
            ),
            Tome.new(
              'uuid'   => SecureRandom.uuid,
              'title'  => 'Princess Floralinda and the Forty Flight Tower',
              'author' => 'Tamsyn Muir',
              'series' => nil
            )
          ]
        end
        let(:resource_options) { super().merge(default_order: :uuid) }

        before(:example) { entities.map(&:save!) }

        include_contract 'should find the entities',
          existing_entities: -> { entities.sort_by(&:uuid) }

        describe 'with a filter' do
          let(:matching_entities) do
            entities.select { |entity| entity.series == 'The Locked Tomb' }
          end

          include_contract 'should find the entities',
            existing_entities: -> { matching_entities.sort_by(&:id) },
            params:            { 'where' => { 'series' => 'The Locked Tomb' } }
        end

        describe 'with an ordering' do
          include_contract 'should find the entities',
            existing_entities: -> { entities.sort_by(&:title) },
            params:            { 'order' => 'title' }
        end
      end
    end
    # rubocop:enable Style/RedundantLineContinuation
  end
end
