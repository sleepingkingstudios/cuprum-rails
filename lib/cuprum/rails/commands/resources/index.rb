# frozen_string_literal: true

require 'cuprum/rails/commands/resources'

module Cuprum::Rails::Commands::Resources
  # Command implementing an Index action.
  class Index < Cuprum::Rails::Commands::ResourceCommand
    private

    attr_reader :limit

    attr_reader :offset

    attr_reader :where

    def order
      @order ||= resource.default_order
    end

    def process(limit: nil, offset: nil, order: nil, where: nil)
      @limit  = limit
      @offset = offset
      @order  = order
      @where  = where
      values  = step { collection.find_matching.call(**query_options) }

      values.to_a
    end

    def query_options
      {
        limit:,
        offset:,
        order:,
        where:
      }
    end
  end
end
