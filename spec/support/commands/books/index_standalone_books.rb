# frozen_string_literal: true

require 'cuprum/rails/commands/resources/index'

require 'support/commands/books'

module Spec::Support::Commands::Books
  class IndexStandaloneBooks < Cuprum::Rails::Commands::Resources::Index
    private

    def order
      @order ||= { 'published_at' => 'asc' }
    end

    def where
      (super || {}).merge(series: nil)
    end
  end
end
