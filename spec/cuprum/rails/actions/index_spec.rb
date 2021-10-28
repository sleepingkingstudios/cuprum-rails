# frozen_string_literal: true

require 'cuprum/collections/rspec/fixtures'

require 'cuprum/rails/actions/index'

require 'support/book'
require 'support/examples/action_examples'

RSpec.describe Cuprum::Rails::Actions::Index do
  include Spec::Support::Examples::ActionExamples

  subject(:action) { described_class.new(resource: resource) }

  shared_context 'with a request with parameters' do
    let(:params)  { {} }
    let(:request) { instance_double(Cuprum::Rails::Request, params: params) }

    before(:example) do
      allow(action).to receive(:request).and_return(request) # rubocop:disable RSpec/SubjectStub
    end
  end

  let(:resource_class) { Book }
  let(:collection) do
    Cuprum::Rails::Collection.new(record_class: resource_class)
  end
  let(:resource) do
    Cuprum::Rails::Resource.new(
      collection:     collection,
      resource_class: resource_class,
      **resource_options
    )
  end
  let(:resource_options) { {} }

  include_examples 'should define the ResourceAction methods'

  describe '#call' do
    let(:params)  { {} }
    let(:request) { instance_double(ActionDispatch::Request, params: params) }
    let(:data)    { [] }
    let(:matching_data) do
      resource_class.all
    end
    let(:expected_value) do
      { resource.resource_name => matching_data.to_a }
    end

    before(:example) do
      data.each do |attributes|
        resource_class.create!(attributes.except('id'))
      end
    end

    it 'should return a passing result with the matching data' do
      expect(action.call(request: request))
        .to be_a_passing_result
        .with_value(expected_value)
    end

    context 'when the collection has many items' do
      let(:data) { Cuprum::Collections::RSpec::BOOKS_FIXTURES }

      it 'should return a passing result with the matching data' do
        expect(action.call(request: request))
          .to be_a_passing_result
          .with_value(expected_value)
      end

      context 'when the resource has a default order' do
        let(:default_order) { { author: :asc, title: :asc } }
        let(:resource_options) do
          super().merge(default_order: default_order)
        end
        let(:matching_data) do
          super().order(default_order)
        end

        it 'should return a passing result with the matching data' do
          expect(action.call(request: request))
            .to be_a_passing_result
            .with_value(expected_value)
        end

        context 'when the request has an order parameter' do
          let(:params)        { super().merge('order' => %w[author title]) }
          let(:matching_data) { super().order(params['order']) }

          it 'should return a passing result with the matching data' do
            expect(action.call(request: request))
              .to be_a_passing_result
              .with_value(expected_value)
          end
        end

        context 'when the request has filter parameters' do
          let(:params) do
            super().merge(
              'limit'  => 3,
              'offset' => 2,
              'order'  => %w[author title],
              'where'  => { 'series' => nil }
            )
          end
          let(:matching_data) do
            super()
              .limit(params['limit'])
              .offset(params['offset'])
              .order(params['order'])
              .where(params['where'])
          end

          it 'should return a passing result with the matching data' do
            expect(action.call(request: request))
              .to be_a_passing_result
              .with_value(expected_value)
          end
        end
      end

      context 'when the request has a limit parameter' do
        let(:params)        { super().merge('limit' => 3) }
        let(:matching_data) { super().limit(params['limit']) }

        it 'should return a passing result with the matching data' do
          expect(action.call(request: request))
            .to be_a_passing_result
            .with_value(expected_value)
        end
      end

      context 'when the request has an offset parameter' do
        let(:params)        { super().merge('offset' => 1) }
        let(:matching_data) { super().offset(params['offset']) }

        it 'should return a passing result with the matching data' do
          expect(action.call(request: request))
            .to be_a_passing_result
            .with_value(expected_value)
        end
      end

      context 'when the request has an order parameter' do
        let(:params)        { super().merge('order' => %w[author title]) }
        let(:matching_data) { super().order(params['order']) }

        it 'should return a passing result with the matching data' do
          expect(action.call(request: request))
            .to be_a_passing_result
            .with_value(expected_value)
        end
      end

      context 'when the request has a where parameter' do
        let(:params)        { super().merge('where' => { 'series' => nil }) }
        let(:matching_data) { super().where(params['where']) }

        it 'should return a passing result with the matching data' do
          expect(action.call(request: request))
            .to be_a_passing_result
            .with_value(expected_value)
        end
      end

      context 'when the request has filter parameters' do
        let(:params) do
          super().merge(
            'limit'  => 3,
            'offset' => 2,
            'order'  => %w[author title],
            'where'  => { 'series' => nil }
          )
        end
        let(:matching_data) do
          super()
            .limit(params['limit'])
            .offset(params['offset'])
            .order(params['order'])
            .where(params['where'])
        end

        it 'should return a passing result with the matching data' do
          expect(action.call(request: request))
            .to be_a_passing_result
            .with_value(expected_value)
        end
      end
    end
  end

  describe '#default_order' do
    include_examples 'should define reader', :default_order, {}

    context 'when the resource has a default order' do
      let(:default_order) { { author: :asc, title: :asc } }
      let(:resource_options) do
        super().merge(default_order: default_order)
      end

      it { expect(action.default_order).to be == default_order }
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

    include_examples 'should define private reader', :order, nil

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
end
