# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Namespace for response objects, which encapsulate server responses.
  module Responses
    autoload :HeadResponse, 'cuprum/rails/responses/head_response'
    autoload :Html,         'cuprum/rails/responses/html'
    autoload :HtmlResponse, 'cuprum/rails/responses/html_response'
    autoload :JsonResponse, 'cuprum/rails/responses/json_response'
  end
end
