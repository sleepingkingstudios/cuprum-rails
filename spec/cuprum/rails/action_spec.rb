# frozen_string_literal: true

require 'cuprum/rails/action'
require 'cuprum/rails/repository'

require 'support/examples/action_examples'

RSpec.describe Cuprum::Rails::Action do
  include Spec::Support::Examples::ActionExamples

  subject(:action) do
    described_class.new(resource: resource, **constructor_options)
  end

  let(:resource) do
    Cuprum::Rails::Resource.new(resource_name: 'books')
  end
  let(:constructor_options) { {} }

  def be_callable
    respond_to(:process, true)
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:repository, :resource)
        .and_any_keywords
    end
  end

  describe '#call' do
    let(:request) { instance_double(ActionDispatch::Request) }

    it 'should define the method' do
      expect(action).to be_callable.with(0).arguments.and_keywords(:request)
    end

    it 'should return a passing result' do
      expect(action.call(request: request))
        .to be_a_passing_result.with_value(nil)
    end
  end

  describe '#options' do
    include_examples 'should define reader', :options, -> { {} }

    context 'when initialized with options' do
      let(:options)             { { key: 'value' } }
      let(:constructor_options) { super().merge(options) }

      it { expect(action.options).to be == options }
    end
  end

  describe '#params' do
    include_context 'when the action is called with a request'

    it 'should define the private method' do
      expect(action).to respond_to(:params, true).with(0).arguments
    end

    it { expect(action.send(:params)).to be_a ActionController::Parameters }

    it { expect(action.send(:params).to_unsafe_hash).to be == params }

    context 'when the request has parameters' do
      let(:params) do
        {
          'book' => {
            'title' => 'Tamsyn Muir'
          },
          'key'  => 'value'
        }
      end

      it { expect(action.send(:params).to_unsafe_hash).to be == params }
    end
  end

  describe '#resource' do
    include_examples 'should define reader', :resource, -> { resource }
  end

  describe '#repository' do
    include_examples 'should define reader', :repository, nil

    context 'when initialized with a repository' do
      let(:repository)          { Cuprum::Rails::Repository.new }
      let(:constructor_options) { super().merge(repository: repository) }

      it { expect(action.repository).to be repository }
    end
  end
end
