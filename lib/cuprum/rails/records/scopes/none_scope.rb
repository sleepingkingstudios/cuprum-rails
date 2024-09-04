# frozen_string_literal: true

require 'cuprum/collections/scopes/none'

require 'cuprum/rails/records/scopes'
require 'cuprum/rails/records/scopes/base'

module Cuprum::Rails::Records::Scopes
  # Scope for returning an empty data set.
  class NoneScope < Cuprum::Rails::Records::Scopes::Base
    include Cuprum::Collections::Scopes::None

    # @return [Cuprum::Collections::Rails::Scopes::NoneScope] a cached instance
    #   of the none scope.
    def self.instance
      @instance ||= new
    end

    private

    def process(native_query:)
      native_query.none
    end
  end
end
