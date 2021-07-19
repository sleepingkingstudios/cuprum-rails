# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Namespace for responders, which process action results into responses.
  module Responders
    autoload :Matching, 'cuprum/rails/responders/matching'
  end
end
