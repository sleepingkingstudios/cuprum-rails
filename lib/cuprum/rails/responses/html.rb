# frozen_string_literal: true

require 'cuprum/rails/responses'

module Cuprum::Rails::Responses
  # Namespace for response objects, which encapsulate Html responses.
  module Html
    autoload :RedirectResponse, 'cuprum/rails/responses/html/redirect_response'
    autoload :RenderResponse,   'cuprum/rails/responses/html/render_response'
  end
end
