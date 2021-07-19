# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Namespace for response objects, which encapsulate server responses.
  module Responses
    autoload :Html, 'cuprum/rails/responses/html'
  end
end
