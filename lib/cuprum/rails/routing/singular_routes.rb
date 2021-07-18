# frozen_string_literal: true

require 'cuprum/rails/routing'

module Cuprum::Rails::Routing
  # Routes object with predefined routes for a singular RESTful resource.
  #
  # The following route helpers are defined:
  #
  # - #create_path  => '/' or '/path/to/resource/'
  # - #destroy_path => '/' or '/path/to/resource/'
  # - #edit_path    => '/edit' or '/path/to/resource/edit'
  # - #new_path     => '/new' or '/path/to/resource/new'
  # - #show_path    => '/' or '/path/to/resource/'
  # - #update_path  => '/' or '/path/to/resource/'
  class SingularRoutes < Cuprum::Rails::Routes
    route :create,  ''
    route :destroy, ''
    route :edit,    'edit'
    route :new,     'new'
    route :show,    ''
    route :update,  ''
  end
end
