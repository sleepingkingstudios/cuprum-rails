# frozen_string_literal: true

require 'cuprum/rails/actions/middleware/log_request'

RSpec.describe Cuprum::Rails::Actions::Middleware::LogRequest do
  subject(:middleware) { described_class.new(**config) }

  let(:config) { {} }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_any_keywords
    end
  end

  describe '#call' do
    shared_examples 'should log the request properties' \
    do |except: [], including: []|
      expected_properties = %i[
        action_name
        body_params
        controller_name
        format
        http_method
        params
        path
        path_params
        query_params
      ]
      expected_properties += Array(including)
      expected_properties -= Array(except)
      expected_properties -= %i[command_options repository resource]

      excluded_properties = %i[
        authorization
        command_options
        headers
        repository
        resource
      ]
      excluded_properties -= Array(including)
      excluded_properties += Array(except)
      excluded_properties -= %i[command_options repository resource]

      if Array(including).include?(:command_options)
        it 'should log the command options' do
          expected = "    Command Options\n#{format_value(options)}"

          expect(logged).to include expected
        end
      else
        it 'should not log the command options' do
          expected = "    Command Options\n"

          expect(logged).not_to include expected
        end
      end

      if Array(including).include?(:repository)
        it 'should log the repository' do
          expected = "    Repository\n#{format_value(repository)}"

          expect(logged).to include expected
        end
      else
        it 'should not log the repository' do
          expected = "    Repository\n"

          expect(logged).not_to include expected
        end
      end

      if Array(including).include?(:resource)
        it 'should log the resource' do
          expected = "    Resource\n#{format_value(resource)}"

          expect(logged).to include expected
        end
      else
        it 'should not log the resource' do
          expected = "    Resource\n"

          expect(logged).not_to include expected
        end
      end

      expected_properties.each do |property|
        it "should log the request #{property.to_s.tr('_', ' ')}" do
          label    = property.to_s.titleize
          value    = request.send(property)
          expected = "    #{label}\n#{format_value(value)}"

          expect(logged).to include expected
        end
      end

      excluded_properties.each do |property|
        it "should not log the request #{property.to_s.tr('_', ' ')}" do
          label    = property.to_s.titleize
          expected = "    #{label}\n"

          expect(logged).not_to include expected
        end
      end
    end

    let(:next_result) do
      Cuprum::Rails::Result.new(
        value:    { 'ok' => true },
        metadata: { 'env' => :test }
      )
    end
    let(:next_command) do
      instance_double(Cuprum::Command, call: next_result)
    end
    let(:request) do
      Cuprum::Rails::Request.new(
        action_name:     :launch,
        authorization:   'Bearer 12345',
        body_params:     { 'launch_site' => 'KSC' },
        controller_name: 'rockets',
        format:          :html,
        headers:         { 'authorization' => 'Bearer 12345' },
        http_method:     :patch,
        params:          {
          controller:  'rockets',
          action:      'launch',
          launch_site: 'KSC',
          rocket_id:   'imp-iv',
          countdown:   'T-Minus 10 seconds'
        },
        path:            '/rockets/imp-iv/launch',
        path_params:     { 'rocket_id' => 'imp-iv' },
        query_params:    { 'countdown' => 'T-Minus 10 seconds' }
      )
    end
    let(:repository) { Cuprum::Rails::Repository.new }
    let(:resource)   { Cuprum::Rails::Resource.new(name: 'books') }
    let(:logger)     { instance_double(ActiveSupport::Logger, info: nil) }
    let(:options)    { {} }
    let(:expected) do
      <<~TEXT.then { |str| format_expected(str) }
        Cuprum::Rails::Actions::Middleware::LogRequest#process
          Action Name
            :launch

          Body Params
            {"launch_site"=>"KSC"}

          Controller Name
            "rockets"

          Format
            :html

          Http Method
            :patch

          Params
            {:controller=>"rockets",
             :action=>"launch",
             :launch_site=>"KSC",
             :rocket_id=>"imp-iv",
             :countdown=>"T-Minus 10 seconds"}

          Path
            "/rockets/imp-iv/launch"

          Path Params
            {"rocket_id"=>"imp-iv"}

          Query Params
            {"countdown"=>"T-Minus 10 seconds"}
      TEXT
    end

    before(:example) do
      allow(Rails).to receive(:logger).and_return(logger)
    end

    def call_middleware
      middleware.call(
        next_command,
        repository:,
        request:,
        resource:,
        **options
      )
    end

    def format_expected(str)
      str
        .lines
        .map { |line| line == "\n" ? "\n" : "  #{line}" }
        .join
    end

    def format_value(value)
      tools.str.indent(value.pretty_inspect, 6)
    end

    def logged
      value = nil

      allow(logger).to receive(:info) { |text| value = text }

      call_middleware

      value
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    it 'should define the method' do
      expect(middleware)
        .to be_callable
        .with(1).argument
        .and_keywords(:request)
        .and_any_keywords
    end

    it 'should call the next command' do # rubocop:disable RSpec/ExampleLength
      call_middleware

      expect(next_command).to have_received(:call).with(
        repository:,
        request:,
        resource:
      )
    end

    it 'should return the next result' do
      expect(call_middleware)
        .to be_a_passing_result
        .with_value({ 'ok' => true })
        .and_metadata({ 'env' => :test })
    end

    it 'should log the request', :aggregate_failures do
      call_middleware

      expect(logger).to have_received(:info)
      expect(logged).to be == expected
    end

    include_examples 'should log the request properties'

    describe 'with custom options' do
      let(:options) { { key: 'custom value' } }

      it 'should call the next command' do # rubocop:disable RSpec/ExampleLength
        call_middleware

        expect(next_command).to have_received(:call).with(
          repository:,
          request:,
          resource:,
          **options
        )
      end

      include_examples 'should log the request properties',
        including: :command_options
    end

    context 'when initialized with action_name: false' do
      let(:config) { super().merge(action_name: false) }

      include_examples 'should log the request properties', except: :action_name
    end

    context 'when initialized with authorization: true' do
      let(:config) { super().merge(authorization: true) }

      include_examples 'should log the request properties',
        including: :authorization
    end

    context 'when initialized with body_params: false' do
      let(:config) { super().merge(body_params: false) }

      include_examples 'should log the request properties', except: :body_params
    end

    context 'when initialized with controller_name: false' do
      let(:config) { super().merge(controller_name: false) }

      include_examples 'should log the request properties',
        except: :controller_name
    end

    context 'when initialized with format: false' do
      let(:config) { super().merge(format: false) }

      include_examples 'should log the request properties', except: :format
    end

    context 'when initialized with headers: true' do
      let(:config) { super().merge(headers: true) }

      include_examples 'should log the request properties', including: :headers
    end

    context 'when initialized with http_method: false' do
      let(:config) { super().merge(http_method: false) }

      include_examples 'should log the request properties', except: :http_method
    end

    context 'when initialized with params: false' do
      let(:config) { super().merge(params: false) }

      include_examples 'should log the request properties', except: :params
    end

    context 'when initialized with path: false' do
      let(:config) { super().merge(path: false) }

      include_examples 'should log the request properties', except: :path
    end

    context 'when initialized with path_params: false' do
      let(:config) { super().merge(path_params: false) }

      include_examples 'should log the request properties', except: :path_params
    end

    context 'when initialized with query_params: false' do
      let(:config) { super().merge(query_params: false) }

      include_examples 'should log the request properties',
        except: :query_params
    end

    context 'when initialized with repository: true' do
      let(:config) { super().merge(repository: true) }

      include_examples 'should log the request properties',
        including: :repository
    end

    context 'when initialized with resource: true' do
      let(:config) { super().merge(resource: true) }

      include_examples 'should log the request properties', including: :resource
    end
  end

  describe '#config' do
    let(:expected) do
      {
        authorization: false,
        headers:       false,
        repository:    false,
        resource:      false
      }
    end

    include_examples 'should define reader', :config, -> { expected }

    context 'when initialized with custom configuration' do
      let(:config) do
        {
          authorization: true,
          path:          false
        }
      end
      let(:expected) { super().merge(config) }

      it { expect(middleware.config).to be == expected }
    end
  end
end
