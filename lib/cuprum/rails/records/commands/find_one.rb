# frozen_string_literal: true

require 'cuprum/collections/commands/abstract_find_one'

require 'cuprum/rails/records/command'
require 'cuprum/rails/records/commands'

module Cuprum::Rails::Records::Commands
  # Command for finding one ActiveRecord record by primary key.
  class FindOne < Cuprum::Rails::Records::Command
    include Cuprum::Collections::Commands::AbstractFindOne

    private

    def process(primary_key:, envelope: false)
      super
    rescue ActiveRecord::StatementInvalid => exception
      failure(invalid_statement_error(exception.message))
    end
  end
end
