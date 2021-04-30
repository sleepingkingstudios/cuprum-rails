# frozen_string_literal: true

require 'cuprum'

# A Ruby implementation of the command pattern.
module Cuprum
  # An integration between Rails and the Cuprum library.
  module Rails
    # @return [String] The current version of the gem.
    def self.version
      VERSION
    end

    autoload :Query, 'cuprum/rails/query'
  end
end
