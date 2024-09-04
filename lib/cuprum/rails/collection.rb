# frozen_string_literal: true

require 'cuprum/rails'
require 'cuprum/rails/records/collection'

module Cuprum::Rails
  # Wraps an ActiveRecord model as a Cuprum collection.
  #
  # @deprecated 0.3.0 Calling Cuprum::Rails::Collection directly is deprecated.
  class Collection < Cuprum::Rails::Records::Collection
    def initialize(...)
      super

      SleepingKingStudios::Tools::Toolbelt.instance.core_tools.deprecate(
        'Cuprum::Rails::Collection',
        'Use Cuprum::Rails::Records::Collection instead'
      )
    end
  end
end
