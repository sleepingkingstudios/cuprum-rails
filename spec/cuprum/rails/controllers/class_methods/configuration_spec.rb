# frozen_string_literal: true

require 'cuprum/rails/controllers/class_methods/configuration'
require 'cuprum/rails/controllers/class_methods/validations'

require 'support/examples/controller_examples'

RSpec.describe Cuprum::Rails::Controllers::ClassMethods::Configuration do
  include Spec::Support::Examples::ControllerExamples

  let(:described_class) { Spec::Controller }

  example_class 'Spec::Controller' do |klass|
    klass.extend Cuprum::Rails::Controllers::ClassMethods::Configuration # rubocop:disable RSpec/DescribedClass
    klass.extend Cuprum::Rails::Controllers::ClassMethods::Validations
  end

  include_examples 'should implement the configuration DSL'
end
