# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # The Records collection wraps ActiveRecord model persistence and querying.
  module Records
    autoload :Collection, 'cuprum/rails/records/collection'
  end
end
