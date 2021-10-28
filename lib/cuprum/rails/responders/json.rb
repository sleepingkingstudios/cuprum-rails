# frozen_string_literal: true

require 'cuprum/rails/responders'

module Cuprum::Rails::Responders
  # Namespace for JSON responders, which process action results into responses.
  module Json
    autoload :Resource, 'cuprum/rails/responders/json/resource'
  end
end
