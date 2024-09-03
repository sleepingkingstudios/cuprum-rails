# frozen_string_literal: true

require 'stannum/errors'

require 'cuprum/rails/errors/invalid_parameters'

RSpec.describe Cuprum::Rails::Errors::InvalidParameters do
  subject(:error) { described_class.new(errors:) }

  let(:errors) do
    Stannum::Errors
      .new
      .tap { |err| err['title'].add('spec.error', message: "can't be blank") }
  end

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.rails.errors.invalid_parameters'
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:errors)
    end
  end

  describe '#as_json' do
    let(:expected_errors) do
      {
        'title' => [
          {
            'data'    => {},
            'path'    => ['title'],
            'message' => "can't be blank",
            'type'    => 'spec.error'
          }
        ]
      }
    end
    let(:expected) do
      {
        'data'    => { 'errors' => expected_errors },
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should define reader', :as_json, -> { be == expected }

    context 'with nested errors' do
      let(:errors) do
        super().tap do |err|
          err['author']['name'].add('spec.error', message: "can't be blank")
        end
      end
      let(:expected_errors) do
        {
          'author.name' => [
            {
              'data'    => {},
              'path'    => %w[author name],
              'message' => "can't be blank",
              'type'    => 'spec.error'
            }
          ],
          'title'       => [
            {
              'data'    => {},
              'path'    => %w[title],
              'message' => "can't be blank",
              'type'    => 'spec.error'
            }
          ]
        }
      end

      it { expect(error.as_json).to be == expected }
    end
  end

  describe '#errors' do
    include_examples 'should define reader', :errors, -> { errors }
  end

  describe '#message' do
    let(:expected) { "invalid request parameters - #{errors.summary}" }

    it { expect(error.message).to be == expected }
  end

  describe '#type' do
    include_examples 'should define reader', :type, -> { described_class::TYPE }
  end
end
