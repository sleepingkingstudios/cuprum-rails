# frozen_string_literal: true

require 'cuprum/collections/errors/failed_validation'

require 'cuprum/rails/responders/html'
require 'cuprum/rails/responders/html/resource'

module Cuprum::Rails::Responders::Html
  # Defines default responses for a singular RESTful resource.
  #
  # - #create failure: renders the :new template.
  # - #create success: redirects to the resource #show page.
  # - #destroy success: redirects to the parent resource.
  # - #update failure: renders the :edit template.
  # - #update success: redirects to the resource #show page.
  #
  # Responds to any other successful result by rendering the template for the
  # action name and passing the result value as assigned variables. For a
  # failing result, redirects to the parent resource.
  class SingularResource < Cuprum::Rails::Responders::Html::Resource
    def initialize(**options)
      super

      SleepingKingStudios::Tools::CoreTools.deprecate(
        'Cuprum::Rails::Responders::Html::SingularResource',
        message: 'use Cuprum::Rails::Responders::Html::Resource'
      )
    end
  end
end
