# frozen_string_literal: true

require 'cuprum/rails/commands/resources/index'

require 'support/examples/commands/resource_command_examples'

RSpec.describe Cuprum::Rails::Commands::Resources::Index do
  include Spec::Support::Examples::Commands::ResourceCommandExamples

  subject(:command) { described_class.new(repository:, resource:) }

  include_deferred 'with parameters for a resource command'

  include_deferred 'should implement the resource command methods'

  describe '#call' do
    let(:matching_values)      { [] }
    let(:find_matching_result) { Cuprum::Result.new(value: matching_values) }
    let(:find_matching) do
      instance_double(
        Cuprum::Collections::Basic::Commands::FindMatching,
        call: find_matching_result
      )
    end
    let(:options) { {} }
    let(:expected_options) do
      {
        limit:  nil,
        offset: nil,
        order:  resource.default_order,
        where:  nil
      }.merge(options)
    end

    before(:example) do
      collection =
        repository.find_or_create(qualified_name: resource.qualified_name)

      allow(collection).to receive(:find_matching).and_return(find_matching)
    end

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:limit, :offset, :order, :where)
    end

    it 'should call the collection' do
      command.call(**options)

      expect(find_matching).to have_received(:call).with(**expected_options)
    end

    it 'should return a passing result' do
      expect(command.call(**options))
        .to be_a_passing_result
        .with_value(matching_values)
    end

    context 'when the collection command returns values' do
      let(:matching_values) do
        Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
      end

      it 'should return a passing result' do
        expect(command.call(**options))
          .to be_a_passing_result
          .with_value(matching_values)
      end
    end

    context 'when the collection command returns a failing result' do
      let(:find_matching_error) do
        Cuprum::Error.new(message: 'Something went wrong')
      end
      let(:find_matching_result) do
        Cuprum::Result.new(error: find_matching_error)
      end

      it 'should return a failing result' do
        expect(command.call(**options))
          .to be_a_failing_result
          .with_error(find_matching_error)
      end
    end

    context 'when the resource defines a default order' do
      let(:resource) do
        Cuprum::Rails::Resource.new(
          name:          'books',
          default_order: { author: :asc }
        )
      end

      it 'should call the collection' do
        command.call(**options)

        expect(find_matching).to have_received(:call).with(**expected_options)
      end
    end

    describe 'with options' do
      let(:options) do
        { limit: 3, order: { title: :desc } }
      end

      it 'should call the collection' do
        command.call(**options)

        expect(find_matching).to have_received(:call).with(**expected_options)
      end
    end
  end
end
