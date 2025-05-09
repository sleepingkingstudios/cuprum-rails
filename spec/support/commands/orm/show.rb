# frozen_string_literal: true

require 'cuprum/rails/commands/resources/show'

require 'support/commands/orm'

module Spec::Support::Commands::Orm
  class Show < Cuprum::Rails::Commands::Resources::Show
    private

    def process(**options)
      record = step { super(**options) }

      Records.new(record_class: collection.entity_class, records: [record])
    end
  end
end
