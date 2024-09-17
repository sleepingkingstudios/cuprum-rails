# frozen_string_literal: true

require 'cuprum/rails/actions/resources/index'

RSpec.describe Cuprum::Rails::Actions::Resources::Index do
  subject(:action) { described_class.new(**options) }

  shared_context 'when initialized with a command class' do
    example_class 'Spec::CustomCommand', Cuprum::Rails::Command

    let(:options) { super().merge(command_class: Spec::CustomCommand) }
  end

  let(:options) { {} }

  describe '#call' do
    shared_examples 'should wrap the command' do |class_or_name|
      let(:command_class) do
        return class_or_name if class_or_name.is_a?(Class)

        Object.const_get(class_or_name)
      end
      let(:result)  { Cuprum::Result.new(value: []) }
      let(:command) { instance_double(Cuprum::Command, call: result) }
      let(:expected_parameters) do
        {
          limit:  nil,
          offset: nil,
          order:  nil,
          where:  nil
        }.merge(params)
      end
      let(:expected_value) do
        { 'books' => result.value }
      end

      before(:example) do
        allow(command_class).to receive(:new).and_return(command)
      end

      it 'should initialize the command' do
        call_action

        expect(command_class)
          .to have_received(:new)
          .with(repository:, resource:)
      end

      it 'should call the command' do
        call_action

        expect(command).to have_received(:call).with(**expected_parameters)
      end

      it 'should return a passing result' do
        expect(call_action)
          .to be_a_passing_result
          .with_value(expected_value)
      end

      describe 'with request parameters' do
        let(:params) do
          {
            limit:  3,
            offset: 2,
            order:  { 'title' => :asc },
            where:  { 'author' => 'Tamsyn Muir' }
          }
        end

        it 'should call the command' do
          call_action

          expect(command).to have_received(:call).with(**expected_parameters)
        end
      end

      context 'when the command returns a failing result' do
        let(:expected_error) do
          Cuprum::Error.new(message: 'Something went wrong')
        end
        let(:result) { Cuprum::Result.new(error: expected_error) }

        it 'should return a failing result' do
          expect(call_action)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end

    let(:params)     { {} }
    let(:repository) { Cuprum::Collections::Basic::Repository.new }
    let(:resource)   { Cuprum::Rails::Resource.new(name: 'books') }
    let(:request)    { instance_double(Cuprum::Rails::Request, params:) }

    def call_action
      action.call(repository:, request:, resource:)
    end

    include_examples 'should wrap the command',
      Cuprum::Rails::Commands::Resources::Index

    wrap_context 'when initialized with a command class' do
      include_examples 'should wrap the command', 'Spec::CustomCommand'
    end
  end

  describe '#command_class' do
    include_examples 'should define private reader',
      :command_class,
      Cuprum::Rails::Commands::Resources::Index

    wrap_context 'when initialized with a command class' do
      it { expect(action.send(:command_class)).to be Spec::CustomCommand }
    end
  end
end
