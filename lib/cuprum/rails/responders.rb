# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Namespace for responders, which process action results into responses.
  module Responders
    autoload :Actions,       'cuprum/rails/responders/actions'
    autoload :BaseResponder, 'cuprum/rails/responders/base_responder'
    autoload :Html,          'cuprum/rails/responders/html'
    autoload :HtmlResponder, 'cuprum/rails/responders/html_responder'
    autoload :Json,          'cuprum/rails/responders/json'
    autoload :JsonResponder, 'cuprum/rails/responders/json_responder'
    autoload :Matching,      'cuprum/rails/responders/matching'
  end
end
