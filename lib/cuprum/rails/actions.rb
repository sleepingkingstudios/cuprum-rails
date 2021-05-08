# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Namespace for defined resourceful actions.
  module Actions
    autoload :Create,  'cuprum/rails/actions/create'
    autoload :Destroy, 'cuprum/rails/actions/destroy'
    autoload :Index,   'cuprum/rails/actions/index'
  end
end
