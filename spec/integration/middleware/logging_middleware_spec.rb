# frozen_string_literal: true

require 'support/book'
require 'support/middleware/logging_middleware'
require 'support/tome'

# @note Integration spec for Controller middleware.
RSpec.describe Spec::Support::Middleware::LoggingMiddleware do
  subject(:middleware) { described_class.new }

  let(:repository) do
    repository = Cuprum::Rails::Repository.new

    repository.find_or_create(entity_class: Book)
    repository.find_or_create(entity_class: Tome)

    repository
  end
  let(:resource) do
    Cuprum::Rails::Resource.new(name: 'rare_books')
  end
  let(:command) { instance_double(Cuprum::Command, call: result) }
  let(:result)  { Cuprum::Result.new(value: { 'ok' => true }) }
  let(:request) do
    Cuprum::Rails::Request.new(
      action_name:     'publish',
      controller_name: 'api/books'
    )
  end

  before(:example) { described_class.clear_logs }

  describe '.clear_logs' do
    it { expect(described_class).to respond_to(:clear_logs).with(0).arguments }

    context 'when the logs have entries' do
      before(:example) do
        described_class.logs.puts '[INFO] All is well.'
        described_class.logs.puts '[ERROR] Something went wrong?'
        described_class.logs.puts '[FATAL] Oh no.'
      end

      it 'should clear the logs' do
        expect { described_class.clear_logs }
          .to(
            change { described_class.logs.string }
            .to be == ''
          )
      end
    end
  end

  describe '.logs' do
    it { expect(described_class).to respond_to(:logs).with(0).arguments }

    it { expect(described_class.logs).to be_a StringIO }

    it { expect(described_class.logs.string).to be == '' }

    context 'when the logs have entries' do
      let(:expected) do
        <<~RAW
          [INFO] All is well.
          [ERROR] Something went wrong?
          [FATAL] Oh no.
        RAW
      end

      before(:example) do
        described_class.logs.puts '[INFO] All is well.'
        described_class.logs.puts '[ERROR] Something went wrong?'
        described_class.logs.puts '[FATAL] Oh no.'
      end

      it { expect(described_class.logs.string).to be == expected }
    end
  end

  describe '#call' do
    let(:expected) do
      <<~RAW
        [INFO] Action success: api/books#publish
        - repository_keys: books, tomes
        - resource_name: rare_books
      RAW
    end

    def call_command
      middleware.call(
        command,
        repository:,
        request:,
        resource:
      )
    end

    it 'should call the command' do # rubocop:disable RSpec/ExampleLength
      call_command

      expect(command)
        .to have_received(:call)
        .with(
          repository:,
          request:,
          resource:
        )
    end

    it 'should return the result' do
      expect(call_command).to be == result
    end

    it 'should update the logs' do
      call_command

      expect(described_class.logs.string).to be == expected
    end

    context 'when the result is failing' do
      let(:error)  { Cuprum::Error.new(message: 'Something went wrong.') }
      let(:result) { Cuprum::Result.new(error:) }
      let(:expected) do
        <<~RAW
          [ERROR] Action failure: api/books#publish (Something went wrong.)
          - repository_keys: books, tomes
          - resource_name: rare_books
        RAW
      end

      it 'should update the logs' do
        call_command

        expect(described_class.logs.string).to be == expected
      end
    end
  end
end
