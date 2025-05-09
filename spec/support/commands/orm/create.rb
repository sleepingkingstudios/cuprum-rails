# frozen_string_literal: true

require 'cuprum/rails/commands/resources/create'

require 'support/commands/orm'

module Spec::Support::Commands::Orm
  class Create < Cuprum::Rails::Commands::Resources::Create
    private

    def process(**options)
      record = step { super(**options) }

      Records.new(record_class: collection.entity_class, records: [record])
    end
  end
end
