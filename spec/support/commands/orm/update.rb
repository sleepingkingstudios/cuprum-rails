# frozen_string_literal: true

require 'cuprum/rails/commands/resources/update'

require 'support/commands/orm'

module Spec::Support::Commands::Orm
  class Update < Cuprum::Rails::Commands::Resources::Update
    private

    def process(**options)
      result  = steps { super(**options) }
      records = Records.new(
        record_class: collection.entity_class,
        records:      [result.value]
      )

      build_result(
        **result.properties,
        value: records
      )
    end
  end
end
