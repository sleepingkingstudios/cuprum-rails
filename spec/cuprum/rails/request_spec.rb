# frozen_string_literal: true

require 'cuprum/rails/request'

RSpec.describe Cuprum::Rails::Request do
  subject(:request) { described_class.new(**properties) }

  let(:body_params)  { { 'query' => 'value' } }
  let(:format)       { :json }
  let(:headers)      { { 'HTTP_HOST' => 'www.example.com' } }
  let(:method)       { :post }
  let(:params)       { body_params.merge(query_params) }
  let(:path)         { '/projects/1/tasks/2' }
  let(:query_params) { { 'key' => 'value' } }
  let(:properties) do
    {
      body_params:  body_params,
      format:       format,
      headers:      headers,
      method:       method,
      params:       params,
      path:         path,
      query_params: query_params
    }
  end

  describe '.new' do
    let(:expected_keywords) do
      %i[
        action_name
        authorization
        body_params
        controller_name
        format
        headers
        method
        params
        path
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
      expected_params
        .merge({ 'controller' => 'widgets', 'action' => 'purchase' })
    end
    let(:mime_type) { instance_double(Mime::Type, symbol: format) }
    let(:properties) do
      {
        authorization:         nil,
        format:                mime_type,
        fullpath:              path,
        headers:               headers,
        params:                params,
        query_parameters:      query_params,
        request_method_symbol: method,
        request_parameters:    body_params
      }
    end
    let(:request) { instance_double(ActionDispatch::Request, **properties) }
    let(:expected_headers) do
      { 'HTTP_HOST' => 'www.example.com' }
    end
    let(:expected_params) { body_params.merge(query_params) }

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:build)
        .with(0).arguments
        .and_keywords(:action_name, :request, :controller_name)
    end

    it 'should return a request' do
      expect(described_class.build request: request).to be_a described_class
    end

    it 'should set the request action name' do
      expect(described_class.build(request: request).action_name).to be nil
    end

    it 'should set the request authorization' do
      expect(described_class.build(request: request).authorization).to be nil
    end

    it 'should set the request body params' do
      expect(described_class.build(request: request).body_params)
        .to be == body_params
    end

    it 'should set the request controller name' do
      expect(described_class.build(request: request).controller_name).to be nil
    end

    it 'should set the request format' do
      expect(described_class.build(request: request).format).to be format
    end

    it 'should set and filter the request headers' do
      expect(described_class.build(request: request).headers)
        .to be == expected_headers
    end

    it 'should set the request method' do
      expect(described_class.build(request: request).method).to be method
    end

    it 'should set and filter the request params' do
      expect(described_class.build(request: request).params)
        .to be == expected_params
    end

    it 'should set the request path' do
      expect(described_class.build(request: request).path).to be == path
    end

    it 'should set the request query params' do
      expect(described_class.build(request: request).query_params)
        .to be == query_params
    end

    context 'when the request has authorization: value' do
      let(:authorization) { 'Bearer 12345' }
      let(:properties)    { super().merge(authorization: authorization) }

      it 'should set the request authorization' do
        expect(described_class.build(request: request).authorization)
          .to be == authorization
      end
    end

    describe 'with action_name: value' do
      let(:action_name) { :published }

      it 'should set the request action name' do
        expect(
          described_class
            .build(request: request, action_name: action_name)
            .action_name
        ).to be action_name
      end
    end

    describe 'with controller_name: value' do
      let(:controller_name) { 'api/books' }

      it 'should set the request controller name' do
        expect(
          described_class
            .build(request: request, controller_name: controller_name)
            .controller_name
        ).to be == controller_name
      end
    end
  end

  describe '#action_name' do
    include_examples 'should define reader', :action_name, nil

    context 'when initialized with action_name: value' do
      let(:action_name) { :publish }
      let(:properties)  { super().merge(action_name: action_name) }

      it { expect(request.action_name).to be action_name }
    end
  end

  describe '#authorization' do
    include_examples 'should define reader', :authorization, nil

    context 'when initialized with authorization: value' do
      let(:authorization) { 'Bearer 12345' }
      let(:properties)    { super().merge(authorization: authorization) }

      it { expect(request.authorization).to be == authorization }
    end
  end

  describe '#body_params' do
    include_examples 'should define reader',
      :body_params,
      -> { be == body_params }

    it 'should alias the method' do
      expect(described_class.instance_method(:body_parameters))
        .to be == described_class.instance_method(:body_params)
    end
  end

  describe '#controller_name' do
    include_examples 'should define reader', :controller_name, nil

    context 'when initialized with controller_name: value' do
      let(:controller_name) { 'api/books' }
      let(:properties)      { super().merge(controller_name: controller_name) }

      it { expect(request.controller_name).to be == controller_name }
    end
  end

  describe '#format' do
    include_examples 'should define reader', :format, -> { format }
  end

  describe '#headers' do
    include_examples 'should define reader', :headers, -> { be == headers }
  end

  describe '#method' do
    include_examples 'should define reader', :method, -> { method }
  end

  describe '#params' do
    include_examples 'should define reader', :params, -> { be == params }

    it 'should alias the method' do
      expect(described_class.instance_method(:parameters))
        .to be == described_class.instance_method(:params)
    end
  end

  describe '#path' do
    include_examples 'should define reader', :path, -> { be == path }
  end

  describe '#query_params' do
    include_examples 'should define reader',
      :query_params,
      -> { be == query_params }

    it 'should alias the method' do
      expect(described_class.instance_method(:query_parameters))
        .to be == described_class.instance_method(:query_params)
    end
  end
end
