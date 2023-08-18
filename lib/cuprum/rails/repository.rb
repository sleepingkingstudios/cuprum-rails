# frozen_string_literal: true

require 'cuprum/collections/repository'

require 'cuprum/rails'
require 'cuprum/rails/collection'

module Cuprum::Rails
  # A repository represents a group of Rails collections.
  class Repository < Cuprum::Collections::Repository
    private

    def build_collection(**options)
      Cuprum::Rails::Collection.new(**options)
    end

    def valid_collection?(collection)
      collection.is_a?(Cuprum::Rails::Collection)
    end
  end
end
