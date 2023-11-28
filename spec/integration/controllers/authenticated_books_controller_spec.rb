# frozen_string_literal: true

require 'cuprum/collections/rspec/fixtures'

require 'support/controllers/authenticated_books_controller'

# @note Integration spec for Cuprum::Rails::Controller inheritance.
RSpec.describe AuthenticatedBooksController do
  subject(:controller) do
    described_class.new(
      renderer: renderer,
      request:  request
    )
  end

  shared_context 'when there are many books' do
    before(:example) do
      Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.each do |attributes|
        Book.create!(attributes.except(:id))
      end
    end
  end

  shared_context 'with format: :html' do
    let(:format) { :html }
  end

  shared_context 'with format: :json' do
    let(:format) { :json }
    let(:path)   { "#{super()}.json" }
  end

  shared_examples 'should render the view' do |expected_view|
    include_context 'with format: :html'

    let(:status) { defined?(super()) ? super() : 200 }

    it 'should render the view' do
      controller.send(action_name)

      expect(renderer)
        .to have_received(:render)
        .with((expected_view || action_name), { status: status })
    end

    it 'should assign the queried data' do
      controller.send(action_name)

      expect(assigns).to deep_match(expected_assigns)
    end
  end

  shared_examples 'should serialize the data' do
    include_context 'with format: :json'

    let(:status) { defined?(super()) ? super() : 200 }
    let(:expected_json) do
      {
        'ok'   => true,
        'data' => expected_data
      }
    end

    it 'should render the json' do
      controller.send(action_name)

      expect(renderer)
        .to have_received(:render)
        .with(json: expected_json, status: status)
    end
  end

  let(:action_name)  { nil }
  let(:assigns)      { controller.assigns }
  let(:format)       { :html }
  let(:headers)      { {} }
  let(:params)       { {} }
  let(:query_params) { {} }
  let(:path_params)  { {} }
  let(:renderer) do
    instance_double(Spec::Renderer, redirect_to: nil, render: nil)
  end
  let(:request) do
    combined_params =
      query_params
        .merge(params)
        .merge('action' => action_name, 'controller' => 'books')

    instance_double(
      ActionDispatch::Request,
      authorization:         nil,
      format:                instance_double(Mime::Type, symbol: format),
      fullpath:              path,
      headers:               headers,
      params:                combined_params,
      path_parameters:       path_params,
      query_parameters:      query_params,
      request_method_symbol: method,
      request_parameters:    params
    )
  end
  let(:context) do
    Cuprum::Rails::Serializers::Context.new(
      serializers: Cuprum::Rails::Serializers::Json.default_serializers
    )
  end
  let(:serializer) do
    Spec::Support::Serializers::BookSerializer.new
  end

  example_class 'Spec::Renderer' do |klass|
    klass.define_method(:redirect_to) { |*_, **_| nil }
    klass.define_method(:render)      { |*_, **_| nil }
  end

  before(:example) do
    current_time = Time.current

    allow(Time)
      .to receive(:current)
      .and_return(current_time, current_time + 0.05)
  end

  describe '#index' do
    let(:action_name)    { :index }
    let(:method)         { :get }
    let(:path)           { '/books' }
    let(:expected_books) { [] }
    let(:expected_assigns) do
      {
        '@books'        => expected_books.to_a,
        '@session'      => { 'token' => '12345' },
        '@time_elapsed' => '50 milliseconds'
      }
    end
    let(:expected_data) do
      {
        'books'        => expected_books.map do |book|
          serializer.call(book, context: context)
        end,
        'session'      => { 'token' => '12345' },
        'time_elapsed' => '50 milliseconds'
      }
    end

    it { expect(controller).to respond_to(:index).with(0).arguments }

    wrap_examples 'should render the view'

    wrap_examples 'should serialize the data'

    wrap_context 'when there are many books' do
      let(:expected_books) { Book.order(:id).to_a }

      wrap_examples 'should render the view'

      wrap_examples 'should serialize the data'
    end
  end
end
