# frozen_string_literal: true

require 'cuprum/rails/controllers/class_methods/actions'
require 'cuprum/rails/controllers/class_methods/configuration'
require 'cuprum/rails/controllers/class_methods/validations'

require 'support/examples/controller_examples'

RSpec.describe Cuprum::Rails::Controllers::ClassMethods::Actions do
  include Spec::Support::Examples::ControllerExamples

  subject(:controller) { described_class.new(request) }

  let(:described_class) { Spec::Controller }
  let(:format)          { :html }
  let(:mime_type) do
    instance_double(Mime::Type, symbol: format)
  end
  let(:request) do
    instance_double(ActionDispatch::Request, format: mime_type)
  end

  example_class 'Spec::Controller', Struct.new(:request) do |klass|
    klass.extend Cuprum::Rails::Controllers::ClassMethods::Actions # rubocop:disable RSpec/DescribedClass
    klass.extend Cuprum::Rails::Controllers::ClassMethods::Configuration
    klass.extend Cuprum::Rails::Controllers::ClassMethods::Validations
  end

  include_examples 'should implement the actions DSL'
end
