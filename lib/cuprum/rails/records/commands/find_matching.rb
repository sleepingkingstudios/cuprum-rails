# frozen_string_literal: true

require 'cuprum/collections/commands/abstract_find_matching'

require 'cuprum/rails/records/command'
require 'cuprum/rails/records/commands'

module Cuprum::Rails::Records::Commands
  # Command for querying filtered, ordered data from a Rails collection.
  class FindMatching < Cuprum::Rails::Records::Command
    include Cuprum::Collections::Commands::AbstractFindMatching
  end
end
