# frozen_string_literal: true

require 'cuprum/collections/scopes/none'

require 'cuprum/rails/scopes'
require 'cuprum/rails/scopes/base'

module Cuprum::Rails::Scopes
  # Scope for returning an empty data set.
  class NoneScope < Cuprum::Rails::Scopes::Base
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
