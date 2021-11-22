# frozen_string_literal: true

require 'cuprum/rails/controllers/class_methods/middleware'

require 'support/examples/controller_examples'

RSpec.describe Cuprum::Rails::Controllers::ClassMethods::Middleware do
  include Spec::Support::Examples::ControllerExamples

  let(:described_class) { Spec::Controller }

  example_class 'Spec::Controller' do |klass|
    klass.extend Cuprum::Rails::Controllers::ClassMethods::Middleware # rubocop:disable RSpec/DescribedClass
  end

  include_examples 'should implement the middleware DSL'
end
