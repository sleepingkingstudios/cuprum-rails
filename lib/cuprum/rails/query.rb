# frozen_string_literal: true

require 'cuprum/rails'
require 'cuprum/rails/records/query'

module Cuprum::Rails
  # Interface for performing query operations on a Rails collection.
  #
  # @deprecated 0.3.0 Calling Cuprum::Rails::Collection directly is deprecated.
  class Query < Cuprum::Rails::Records::Query
    def initialize(...)
      super

      SleepingKingStudios::Tools::Toolbelt.instance.core_tools.deprecate(
        'Cuprum::Rails::Query',
        'Use Cuprum::Rails::Records::Query instead'
      )
    end
  end
end
