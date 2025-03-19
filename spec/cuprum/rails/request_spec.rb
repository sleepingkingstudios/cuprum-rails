# frozen_string_literal: true

require 'cuprum/rails/request'

RSpec.describe Cuprum::Rails::Request do
  subject(:request) { described_class.new(**options) }

  shared_examples 'should define request property' \
  do |property_name, value:, optional: false|
    reader_name = property_name
    writer_name = :"#{property_name}="

    describe "##{reader_name}" do
      include_examples 'should define reader',
        reader_name,
        -> { properties[property_name] }

      if optional
        context "when initialized with #{property_name}: value" do
          let(:properties) { super().merge(property_name => value) }

          it { expect(request.send(reader_name)).to be value }
        end
      end
    end

    describe "##{writer_name}" do
      include_examples 'should define writer', writer_name

      it "should set the #{property_name.to_s.tr '_', ' '}" do
        expect { request.send(writer_name, value) }
          .to change(request, reader_name)
          .to be value
      end

      it 'should update the properties' do
        expect { request.send(writer_name, value) }
          .to change(request, :properties)
          .to be > { property_name => value }
      end
    end
  end

  let(:body_params)  { { 'query' => 'value' } }
  let(:format)       { :json }
  let(:headers)      { { 'HTTP_HOST' => 'www.example.com' } }
  let(:http_method)  { :post }
  let(:path)         { '/projects/1/tasks/2' }
  let(:query_params) { { 'key' => 'value' } }
  let(:path_params) do
    {
      'action'     => 'update',
      'controller' => 'tasks',
      'id'         => 2,
      'project_id' => 1
    }
  end
  let(:params) do
    filtered = path_params.except('action', 'controller')

    body_params.merge(query_params).merge(filtered)
  end
  let(:properties) do
    {
      body_params:,
      format:,
      headers:,
      http_method:,
      params:,
      path:,
      query_params:
    }
  end
  let(:options) { properties }

  describe '.new' do
    let(:expected_keywords) do
      %i[
        action_name
        authorization
        body_params
        context
        controller_name
        format
        headers
        member_action
        method
        params
        path
        path_params
        query_params
      ]
    end

    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(*expected_keywords)
    end
  end

  describe '.build' do
    let(:headers) do
      expected_headers.merge(
        {
          'action_dispatch.secret_key_base' => '12345',
          'puma.socket'                     => instance_double(TCPSocket),
          'rack.url_scheme'                 => 'http'
        }
      )
    end
    let(:params) do
      expected_params.merge(
        {
          'action'     => 'purchase',
          'controller' => 'widgets',
          'format'     => 'xml'
        }
      )
    end
    let(:mime_type) { instance_double(Mime::Type, symbol: format) }
    let(:properties) do
      {
        authorization:         nil,
        format:                mime_type,
        fullpath:              path,
        headers:,
        params:,
        path_parameters:       path_params,
        query_parameters:      query_params,
        request_method_symbol: http_method,
        request_parameters:    body_params
      }
    end
    let(:request) { instance_double(ActionDispatch::Request, **properties) }
    let(:expected_headers) do
      { 'HTTP_HOST' => 'www.example.com' }
    end
    let(:expected_params) do
      filtered = path_params.except('action', 'controller')

      body_params.merge(query_params).merge(filtered)
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:build)
        .with(0).arguments
        .and_keywords(:request)
        .and_any_keywords
    end

    it 'should return a request' do
      expect(described_class.build request:).to be_a described_class
    end

    it 'should set the request action name' do
      expect(described_class.build(request:).action_name)
        .to be params['action'].intern
    end

    it 'should set the request authorization' do
      expect(described_class.build(request:).authorization).to be nil
    end

    it 'should set the request body params' do
      expect(described_class.build(request:).body_params)
        .to be == body_params
    end

    it 'should set the request controller name' do
      expect(described_class.build(request:).controller_name)
        .to be == params['controller']
    end

    it 'should set the request format' do
      expect(described_class.build(request:).format).to be format
    end

    it 'should set and filter the request headers' do
      expect(described_class.build(request:).headers)
        .to be == expected_headers
    end

    it 'should set the request http method' do
      expect(described_class.build(request:).http_method)
        .to be http_method
    end

    it 'should set the member action property' do
      expect(described_class.build(request:).member_action?).to be false
    end

    it 'should set and filter the request params' do
      expect(described_class.build(request:).params)
        .to be == expected_params
    end

    it 'should set the request path' do
      expect(described_class.build(request:).path).to be == path
    end

    it 'should set the request path params' do
      expect(described_class.build(request:).path_params)
        .to be == path_params.except('action', 'controller')
    end

    it 'should set the request query params' do
      expect(described_class.build(request:).query_params)
        .to be == query_params
    end

    context 'when the request has authorization: value' do
      let(:authorization) { 'Bearer 12345' }
      let(:properties)    { super().merge(authorization:) }

      it 'should set the request authorization' do
        expect(described_class.build(request:).authorization)
          .to be == authorization
      end
    end

    context 'when the body params includes a reserved key' do
      let(:body_params) { super().merge({ 'action' => 'PG-13' }) }

      it 'should set the request body params' do
        expect(described_class.build(request:).body_params)
          .to be == body_params
      end

      it 'should set and filter the request params' do
        expect(described_class.build(request:).params)
          .to be == expected_params
      end
    end

    context 'when the query params includes a reserved key' do
      let(:query_params) { super().merge({ 'format' => 'Betamax' }) }

      it 'should set and filter the request params' do
        expect(described_class.build(request:).params)
          .to be == expected_params
      end

      it 'should set the request query params' do
        expect(described_class.build(request:).query_params)
          .to be == query_params
      end
    end

    context 'when the headers are wrapped in ActionDispatch::Http::Headers' do
      let(:headers) { ActionDispatch::Http::Headers.from_hash(super()) }

      it 'should set and filter the request headers' do
        expect(described_class.build(request:).headers)
          .to be == expected_headers
      end
    end

    context 'with a context object' do
      let(:context) { instance_double(ActionController::Base) }

      it 'should return a request' do
        expect(described_class.build(context:, request:))
          .to be_a described_class
      end

      it 'should set the context' do
        expect(
          described_class.build(context:, request:).context
        )
          .to be context
      end
    end

    describe 'with custom properties' do
      let(:options) { { custom_key: 'custom value' } }

      it 'should return a request' do
        expect(described_class.build(request:, **options))
          .to be_a described_class
      end

      it 'should set the request properties' do
        expect(described_class.build(request:, **options)['custom_key'])
          .to be == 'custom value'
      end
    end

    describe 'with member_action: true' do
      let(:options) { { member_action: true } }

      it 'should set the member action property' do
        expect(
          described_class.build(request:, **options).member_action?
        )
          .to be true
      end

      it 'should set the request properties' do
        expect(
          described_class.build(request:, **options)['member_action']
        )
          .to be true
      end
    end
  end

  include_examples 'should define request property',
    :action_name,
    optional: true,
    value:    :publish

  include_examples 'should define request property',
    :authorization,
    optional: true,
    value:    'Bearer 12345'

  include_examples 'should define request property',
    :body_params,
    value: { 'foo' => 'bar' }

  include_examples 'should define request property',
    :controller_name,
    optional: true,
    value:    'api/books'

  include_examples 'should define request property',
    :format,
    value: :html

  include_examples 'should define request property',
    :headers,
    value: { 'foo' => 'bar' }

  include_examples 'should define request property',
    :http_method,
    value: :get

  include_examples 'should define request property',
    :params,
    value: { 'foo' => 'bar' }

  include_examples 'should define request property',
    :path,
    value: '/api/books/0/publish'

  include_examples 'should define request property',
    :path_params,
    value: { 'foo' => 'bar' }

  include_examples 'should define request property',
    :query_params,
    value: { 'foo' => 'bar' }

  describe '#[]' do
    it { expect(request).to respond_to(:[]).with(1).argument }

    describe 'with nil' do
      let(:error_message) { "property name can't be blank" }

      it 'should raise an exception' do
        expect { request[nil] }.to raise_error ArgumentError, error_message
      end
    end

    describe 'with an object' do
      let(:error_message) { 'property name must be a String or a Symbol' }

      it 'should raise an exception' do
        expect { request[Object.new.freeze] }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty string' do
      let(:error_message) { "property name can't be blank" }

      it 'should raise an exception' do
        expect { request[''] }.to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty symbol' do
      let(:error_message) { "property name can't be blank" }

      it 'should raise an exception' do
        expect { request[:''] }.to raise_error ArgumentError, error_message
      end
    end

    describe 'with a new property name string' do
      it { expect(request['session']).to be nil }
    end

    describe 'with a new property name symbol' do
      it { expect(request[:session]).to be nil }
    end

    describe 'with an existing property name string' do
      it { expect(request['http_method']).to be http_method }
    end

    describe 'with an existing property name symbol' do
      it { expect(request[:http_method]).to be http_method }
    end
  end

  describe '#[]=' do
    it { expect(request).to respond_to(:[]=).with(2).arguments }

    describe 'with nil' do
      let(:error_message) { "property name can't be blank" }

      it 'should raise an exception' do
        expect { request[nil] = nil }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an object' do
      let(:error_message) { 'property name must be a String or a Symbol' }

      it 'should raise an exception' do
        expect { request[Object.new.freeze] = nil }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty string' do
      let(:error_message) { "property name can't be blank" }

      it 'should raise an exception' do
        expect { request[''] = nil }.to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty symbol' do
      let(:error_message) { "property name can't be blank" }

      it 'should raise an exception' do
        expect { request[:''] = nil }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a new property name string' do
      let(:value) { Object.new.freeze }

      it 'should update the properties' do
        expect { request['session'] = value }
          .to change(request, :properties)
          .to be > { session: value }
      end
    end

    describe 'with a new property name symbol' do
      let(:value) { Object.new.freeze }

      it 'should update the properties' do
        expect { request[:session] = value }
          .to change(request, :properties)
          .to be > { session: value }
      end
    end

    describe 'with an existing property name string' do
      let(:value) { :patch }

      it 'should set the http method' do
        expect { request['http_method'] = value }
          .to change(request, :http_method)
          .to be value
      end

      it 'should update the properties' do
        expect { request['http_method'] = value }
          .to change(request, :properties)
          .to be > { http_method: value }
      end
    end

    describe 'with an existing property name symbol' do
      let(:value) { :patch }

      it 'should set the http method' do
        expect { request[:http_method] = value }
          .to change(request, :http_method)
          .to be value
      end

      it 'should update the properties' do
        expect { request[:http_method] = value }
          .to change(request, :properties)
          .to be > { http_method: value }
      end
    end
  end

  describe '#body_parameters' do
    it 'should alias the method' do
      expect(described_class.instance_method(:body_parameters))
        .to be == described_class.instance_method(:body_params)
    end
  end

  describe '#body_parameters=' do
    it 'should alias the method' do
      expect(described_class.instance_method(:body_parameters=))
        .to be == described_class.instance_method(:body_params=)
    end
  end

  describe '#context' do
    include_examples 'should define reader', :context, nil

    context 'when initialized with context: a controller' do
      let(:context) { instance_double(ActionController::Base) }
      let(:options) { super().merge(context:) }

      it { expect(request.context).to be context }
    end
  end

  describe '#member_action?' do
    include_examples 'should define predicate', :member_action?, false

    context 'when initialized with member_action: false' do
      let(:options) { super().merge(member_action: false) }

      it { expect(request.member_action?).to be false }
    end

    context 'when initialized with member_action: true' do
      let(:options) { super().merge(member_action: true) }

      it { expect(request.member_action?).to be true }
    end
  end

  describe '#native_session' do
    include_examples 'should define reader', :native_session, nil

    context 'when initialized with context: a controller' do
      let(:session) { instance_double(ActionDispatch::Request::Session) }
      let(:context) do
        instance_double(ActionController::Base, session:)
      end
      let(:options) { super().merge(context:) }

      it { expect(request.native_session).to be session }
    end
  end

  describe '#parameters' do
    it 'should alias the method' do
      expect(described_class.instance_method(:parameters))
        .to be == described_class.instance_method(:params)
    end
  end

  describe '#parameters=' do
    it 'should alias the method' do
      expect(described_class.instance_method(:parameters=))
        .to be == described_class.instance_method(:params=)
    end
  end

  describe '#path_parameters' do
    it 'should alias the method' do
      expect(request)
        .to have_aliased_method(:path_parameters)
        .as(:path_params)
    end
  end

  describe '#path_parameters=' do
    it 'should alias the method' do
      expect(request)
        .to have_aliased_method(:path_parameters=)
        .as(:path_params=)
    end
  end

  describe '#properties' do
    include_examples 'should define reader',
      :properties,
      -> { be == properties }

    context 'when initialized with action_name: value' do
      let(:action_name) { :publish }
      let(:properties)  { super().merge(action_name:) }

      it { expect(request.properties).to be == properties }
    end

    context 'when initialized with authorization: value' do
      let(:authorization) { 'Bearer 12345' }
      let(:properties)    { super().merge(authorization:) }

      it { expect(request.properties).to be == properties }
    end

    context 'when initialized with controller_name: value' do
      let(:controller_name) { 'api/books' }
      let(:properties)      { super().merge(controller_name:) }

      it { expect(request.properties).to be == properties }
    end

    context 'when initialized with additional properties' do
      let(:properties) { super().merge(session: Object.new.freeze) }

      it { expect(request.properties).to be == properties }
    end
  end

  describe '#query_parameters' do
    it 'should alias the method' do
      expect(described_class.instance_method(:query_parameters))
        .to be == described_class.instance_method(:query_params)
    end
  end

  describe '#query_parameters=' do
    it 'should alias the method' do
      expect(described_class.instance_method(:query_parameters=))
        .to be == described_class.instance_method(:query_params=)
    end
  end
end
