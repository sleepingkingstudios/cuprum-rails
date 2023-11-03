# frozen_string_literal: true

require 'cuprum/rails/routes'
require 'cuprum/rails/rspec/define_route_contract'

require 'support/book'
require 'support/publisher'

RSpec.describe Cuprum::Rails::Routes do
  subject(:routes) do
    described_class.new(base_path: base_path, **options, &block)
  end

  let(:base_path) { '/books' }
  let(:options)   { {} }
  let(:block)     { nil }

  describe '::MissingWildcardError' do
    it { expect(described_class::MissingWildcardError).to be_a Class }

    it { expect(described_class::MissingWildcardError).to be < StandardError }
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:base_path, :parent_path)
        .and_a_block
    end

    describe 'with a block' do
      let(:block) do
        lambda do
          route :published, 'published'
          route :publish,   ':id/publish'
        end
      end
      let(:entity) do
        Book.create!(
          author: 'Tamsyn Muir',
          title:  'Gideon the Ninth'
        )
      end

      include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
        action_name: :published,
        path:        '/books/published'

      include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
        action_name:   :publish,
        member_action: true,
        path:          '/books/:id/publish'
    end
  end

  describe '.route' do
    shared_examples 'should define the collection route helper' \
    do |action_name:, path:, absolute_path: false|
      include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
        action_name: action_name,
        path:        path

      unless absolute_path
        context 'when the base path defines wildcards' do
          let(:base_path) { '/publishers/:publisher_id/books' }

          include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
            action_name: action_name,
            path:        "/publishers/0/#{path}".sub('//', '/'),
            wildcards:   { publisher_id: 0 }

          include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
            action_name: action_name,
            path:        "/publishers/0/#{path}".sub('//', '/'),
            wildcards:   { publisher: Publisher.new(id: 0) }
        end
      end
    end

    shared_examples 'should define the member route helper' \
    do |action_name:, path:, absolute_path: false|
      let(:entity) do
        Book.create!(
          author: 'Tamsyn Muir',
          title:  'Gideon the Ninth'
        )
      end

      include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
        action_name:   action_name,
        member_action: true,
        path:          path

      unless absolute_path
        context 'when the base path defines wildcards' do
          let(:base_path) { '/publishers/:publisher_id/books' }

          include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
            action_name:   action_name,
            member_action: true,
            path:          "/publishers/0/#{path}".sub('//', '/'),
            wildcards:     { publisher_id: 0 }

          include_contract Cuprum::Rails::RSpec::DEFINE_ROUTE_CONTRACT,
            action_name:   action_name,
            member_action: true,
            path:          "/publishers/0/#{path}".sub('//', '/'),
            wildcards:     { publisher: Publisher.new(id: 0) }
        end
      end
    end

    let(:described_class) { Spec::Routes }
    let(:action_name)     { :process }
    let(:path)            { 'process' }

    example_class 'Spec::Routes', Cuprum::Rails::Routes # rubocop:disable RSpec/DescribedClass

    it 'should define the class method' do
      expect(described_class).to respond_to(:route).with(2).arguments
    end

    describe 'with action_name: nil' do
      let(:error_message) do
        'action_name must be a String or Symbol'
      end

      it 'should raise an exception' do
        expect { described_class.route(nil, path) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with action_name: an object' do
      let(:error_message) do
        'action_name must be a String or Symbol'
      end

      it 'should raise an exception' do
        expect { described_class.route(Object.new.freeze, path) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with action_name: an empty string' do
      let(:error_message) do
        "action_name can't be blank"
      end

      it 'should raise an exception' do
        expect { described_class.route('', path) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with action_name: an empty symbol' do
      let(:error_message) do
        "action_name can't be blank"
      end

      it 'should raise an exception' do
        expect { described_class.route(:'', path) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with path: nil' do
      let(:error_message) do
        'path must be a String or Symbol'
      end

      it 'should raise an exception' do
        expect { described_class.route(action_name, nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with path: an object' do
      let(:error_message) do
        'path must be a String or Symbol'
      end

      it 'should raise an exception' do
        expect { described_class.route(action_name, Object.new.freeze) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty path' do
      let(:action_name) { :home }
      let(:path)        { '' }
      let(:options)     { {} }

      before(:example) do
        described_class.route(action_name, path, **options)
      end

      include_examples 'should define the collection route helper',
        action_name: :home,
        path:        '/books'
    end

    describe 'with a collection route' do
      let(:action_name) { :published }
      let(:path)        { 'published' }
      let(:options)     { {} }

      before(:example) do
        described_class.route(action_name, path, **options)
      end

      include_examples 'should define the collection route helper',
        action_name: :published,
        path:        '/books/published'
    end

    describe 'with a member route' do
      let(:action_name) { :publish }
      let(:path)        { ':id/publish' }
      let(:options)     { {} }

      before(:example) do
        described_class.route(action_name, path, **options)
      end

      include_examples 'should define the member route helper',
        action_name: :publish,
        path:        '/books/:id/publish'
    end

    describe 'with an absolute collection path' do
      let(:action_name) { :archived }
      let(:path)        { '/archived/books' }
      let(:options)     { {} }

      before(:example) do
        described_class.route(action_name, path, **options)
      end

      include_examples 'should define the collection route helper',
        absolute_path: true,
        action_name:   :archived,
        path:          '/archived/books'
    end

    describe 'with an absolute member path' do
      let(:action_name) { :archived }
      let(:path)        { '/archived/books/:id' }
      let(:options)     { {} }

      before(:example) do
        described_class.route(action_name, path, **options)
      end

      include_examples 'should define the member route helper',
        absolute_path: true,
        action_name:   :archived,
        path:          '/archived/books/:id'
    end
  end

  describe '#base_path' do
    include_examples 'should define reader', :base_path, -> { be == base_path }
  end

  describe '#parent_path' do
    include_examples 'should define reader', :parent_path, '/'

    context 'when initialized with parent_path: value' do
      let(:error_message) { 'missing wildcard :author_id' }
      let(:parent_path)   { '/authors/:author_id' }
      let(:options)       { super().merge(parent_path: parent_path) }

      it 'should raise an exception' do
        expect { routes.parent_path }
          .to raise_error(
            described_class::MissingWildcardError,
            error_message
          )
      end

      context 'with wildcards' do
        let(:wildcards) { { 'key' => 'value', 'author_id' => '0' } }
        let(:expected)  { '/authors/0' }

        it 'should insert the wildcards' do
          expect(routes.with_wildcards(wildcards).parent_path).to be == expected
        end
      end
    end
  end

  describe '#root_path' do
    include_examples 'should define reader', :root_path, '/'
  end

  describe '#wildcards' do
    include_examples 'should define reader', :wildcards, -> { {} }
  end

  describe '#with_wildcards' do
    let(:error_message) { 'wildcards must be a Hash' }

    it { expect(routes).to respond_to(:with_wildcards).with(1).argument }

    describe 'with nil' do
      it 'should raise an exception' do
        expect { routes.with_wildcards(nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an object' do
      it 'should raise an exception' do
        expect { routes.with_wildcards(Object.new.freeze) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a Hash with string keys' do
      let(:wildcards) do
        {
          'book_id'   => 0,
          'publisher' => Object.new.freeze
        }
      end

      it { expect(routes.with_wildcards(wildcards)).to be_a described_class }

      it { expect(routes.with_wildcards(wildcards)).not_to be routes }

      it 'should set the wildcards' do
        expect(routes.with_wildcards(wildcards).wildcards)
          .to be == wildcards
      end
    end

    describe 'with a Hash with symbol keys' do
      let(:wildcards) do
        {
          book_id:   0,
          publisher: Object.new.freeze
        }
      end

      it { expect(routes.with_wildcards(wildcards)).to be_a described_class }

      it { expect(routes.with_wildcards(wildcards)).not_to be routes }

      it 'should set the wildcards' do
        expect(routes.with_wildcards(wildcards).wildcards)
          .to be == wildcards.stringify_keys
      end
    end
  end
end
