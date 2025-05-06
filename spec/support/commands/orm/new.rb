# frozen_string_literal: true

require 'cuprum/rails/commands/resources/new'

require 'support/commands/orm'

module Spec::Support::Commands::Orm
  class New < Cuprum::Rails::Commands::Resources::New
    private

    def process(**options)
      record = step { super(**options) }

      Records.new(record_class: collection.entity_class, records: [record])
    end
  end
end
