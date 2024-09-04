# frozen_string_literal: true

require 'cuprum/collections/scopes/all'

require 'cuprum/rails/records/scopes'
require 'cuprum/rails/records/scopes/base'

module Cuprum::Rails::Records::Scopes
  # Scope for returning unfiltered data.
  class AllScope < Cuprum::Rails::Records::Scopes::Base
    include Cuprum::Collections::Scopes::All

    # @return [Cuprum::Collections::Rails::Scopes::AllScope] a cached instance
    #   of the all scope.
    def self.instance
      @instance ||= new
    end
  end
end
