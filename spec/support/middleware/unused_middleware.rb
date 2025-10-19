# frozen_string_literal: true

require 'cuprum/middleware'

require 'support/middleware'

module Spec::Support::Middleware
  class UnusedMiddleware < Cuprum::Command
    include Cuprum::Middleware
  end
end
