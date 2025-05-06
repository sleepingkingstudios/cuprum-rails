# frozen_string_literal: true

require 'cuprum/rails/commands/resources/index'

require 'support/commands/orm'

module Spec::Support::Commands::Orm
  class Index < Cuprum::Rails::Commands::Resources::Index
    private

    def process(**options)
      records = step { super(**options) }

      Records.new(record_class: collection.entity_class, records:)
    end
  end
end
