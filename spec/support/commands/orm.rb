# frozen_string_literal: true

require 'support/commands'

module Spec::Support::Commands
  module Orm
    Records = Struct.new(:record_class, :records, keyword_init: true)
  end
end
