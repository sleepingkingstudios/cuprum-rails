# frozen_string_literal: true

require 'cuprum/rails/responders'

module Cuprum::Rails::Responders
  # Namespace for HTML responders, which process action results into responses.
  module Html
    autoload :PluralResource,   'cuprum/rails/responders/html/plural_resource'
    autoload :Rendering,        'cuprum/rails/responders/html/rendering'
    autoload :Resource,         'cuprum/rails/responders/html/resource'
    autoload :SingularResource, 'cuprum/rails/responders/html/singular_resource'
  end
end
