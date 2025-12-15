# frozen_string_literal: true

require 'cuprum/collections/commands/abstract_find_many'

require 'cuprum/rails/records/command'
require 'cuprum/rails/records/commands'

module Cuprum::Rails::Records::Commands
  # Command for finding multiple ActiveRecord records by primary key.
  class FindMany < Cuprum::Rails::Records::Command
    include Cuprum::Collections::Commands::AbstractFindMany

    private

    def process(primary_keys:, allow_partial: false, envelope: false)
      super
    rescue ActiveRecord::StatementInvalid => exception
      failure(invalid_statement_error(exception.message))
    end
  end
end
