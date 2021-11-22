# frozen_string_literal: true

require 'cuprum/rails/controllers/class_methods/actions'
require 'cuprum/rails/controllers/class_methods/configuration'
require 'cuprum/rails/controllers/class_methods/validations'

require 'support/examples/controller_examples'

RSpec.describe Cuprum::Rails::Controllers::ClassMethods::Actions do
  include Spec::Support::Examples::ControllerExamples

  subject(:controller) { described_class.new(native_request) }

  include_context 'with a native request'

  let(:described_class) { Spec::Controller }

  example_class 'Spec::Controller', Struct.new(:request) do |klass|
    klass.extend Cuprum::Rails::Controllers::ClassMethods::Actions # rubocop:disable RSpec/DescribedClass
    klass.extend Cuprum::Rails::Controllers::ClassMethods::Configuration
    klass.extend Cuprum::Rails::Controllers::ClassMethods::Validations

    klass.define_method(:controller_name) { 'api/books' }
  end

  include_examples 'should implement the actions DSL'
end
