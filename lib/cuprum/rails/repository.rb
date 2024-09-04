# frozen_string_literal: true

require 'cuprum/rails'
require 'cuprum/rails/records/repository'

module Cuprum::Rails
  # A repository represents a group of Rails collections.
  #
  # @deprecated 0.3.0 Calling Cuprum::Rails::Repository directly is deprecated.
  class Repository < Cuprum::Rails::Records::Repository
    def initialize(...)
      super

      SleepingKingStudios::Tools::Toolbelt.instance.core_tools.deprecate(
        'Cuprum::Rails::Repository',
        'Use Cuprum::Rails::Records::Repository instead'
      )
    end
  end
end
