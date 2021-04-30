# frozen_string_literal: true

require 'cuprum/rails'

RSpec.describe Cuprum::Rails do
  describe '::VERSION' do
    include_examples 'should define constant',
      :VERSION,
      -> { be == Cuprum::Rails::Version.to_gem_version }
  end

  describe '.version' do
    include_examples 'should define class reader',
      :version,
      -> { be == Cuprum::Rails::Version.to_gem_version }
  end
end
