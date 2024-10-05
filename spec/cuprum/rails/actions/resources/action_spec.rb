# frozen_string_literal: true

require 'cuprum/rails/actions/resources/action'

require 'support/examples/actions/resource_action_examples'

RSpec.describe Cuprum::Rails::Actions::Resources::Action do
  include Spec::Support::Examples::Actions::ResourceActionExamples

  subject(:action) { described_class.new(**options) }

  let(:command_class) { Cuprum::Rails::Command.subclass(&:itself) }
  let(:options)       { { command_class: } }

  include_deferred 'should implement the resource action methods',
    command_class: -> { command_class }

  describe '#call' do
    let(:params)          { { secret: '12345' } }
    let(:repository)      { Cuprum::Collections::Basic::Repository.new }
    let(:resource)        { Cuprum::Rails::Resource.new(name: 'books') }
    let(:request)         { instance_double(Cuprum::Rails::Request, params:) }
    let(:resource_params) { {} }
    let(:expected_value) do
      { resource.singular_name => { attributes: resource_params } }
    end

    def call_action
      action.call(repository:, request:, resource:)
    end

    it 'should return a passing result' do
      expect(call_action)
        .to be_a_passing_result
        .with_value(expected_value)
    end

    describe 'with params: { resource_name: an empty Hash }' do
      let(:params) { super().merge('book' => resource_params) }

      it 'should return a passing result' do
        expect(call_action)
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end

    describe 'with params: { resource_name: a non-empty Hash }' do
      let(:resource_params) do
        {
          'title'  => 'Gideon the Ninth',
          'author' => 'Tamsyn Muir'
        }
      end
      let(:params) { super().merge('book' => resource_params) }

      it 'should return a passing result' do
        expect(call_action)
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end
  end
end
