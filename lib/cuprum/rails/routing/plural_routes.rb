# frozen_string_literal: true

require 'cuprum/rails/routing'

module Cuprum::Rails::Routing
  # Routes object with predefined routes for a RESTful resource.
  #
  # The following route helpers are defined:
  #
  # - #create_path  => '/' or '/path/to/resource/'
  # - #destroy_path => '/:id' or '/path/to/resource/:id'
  # - #edit_path    => '/:id/edit' or '/path/to/resource/:id/edit'
  # - #index_path   => '/' or '/path/to/resource/'
  # - #new_path     => '/new' or '/path/to/resource/new'
  # - #show_path    => '/:id/edit' or '/path/to/resource/:id/edit'
  # - #update_path  => '/:id/edit' or '/path/to/resource/:id/edit'
  class PluralRoutes < Cuprum::Rails::Routes
    route :create,  ''
    route :destroy, ':id'
    route :edit,    ':id/edit'
    route :index,   ''
    route :new,     'new'
    route :show,    ':id'
    route :update,  ':id'
  end
end
