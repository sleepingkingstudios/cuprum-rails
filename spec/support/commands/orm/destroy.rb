# frozen_string_literal: true

require 'cuprum/rails/commands/resources/destroy'

require 'support/commands/orm'

module Spec::Support::Commands::Orm
  class Destroy < Cuprum::Rails::Commands::Resources::Destroy
    private

    def process(**options)
      record = step { super(**options) }

      Records.new(record_class: collection.entity_class, records: [record])
    end
  end
end
