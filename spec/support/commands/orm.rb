# frozen_string_literal: true

require 'support/commands'

module Spec::Support::Commands
  module Orm
    Records = Data.define(:record_class, :records)
  end
end
