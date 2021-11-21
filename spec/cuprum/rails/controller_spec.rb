# frozen_string_literal: true

require 'cuprum/rails/controller'

require 'support/examples/controller_examples'

RSpec.describe Cuprum::Rails::Controller do
  include Spec::Support::Examples::ControllerExamples

  subject(:controller) { described_class.new(native_request) }

  include_context 'with a native request'

  let(:described_class) { Spec::Controller }

  example_class 'Spec::Controller', Struct.new(:request) do |klass|
    klass.include Cuprum::Rails::Controller # rubocop:disable RSpec/DescribedClass
  end

  describe '::UndefinedResourceError' do
    it { expect(described_class::UndefinedResourceError).to be_a Class }

    it { expect(described_class::UndefinedResourceError).to be < StandardError }
  end

  describe '::UnknownFormatError' do
    it { expect(described_class::UnknownFormatError).to be_a Class }

    it { expect(described_class::UnknownFormatError).to be < StandardError }
  end

  include_examples 'should implement the actions DSL'

  include_examples 'should implement the configuration DSL'

  include_examples 'should implement the middleware DSL'
end
