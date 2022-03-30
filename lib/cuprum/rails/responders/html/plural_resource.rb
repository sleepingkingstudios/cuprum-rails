# frozen_string_literal: true

require 'cuprum/collections/errors/failed_validation'

require 'cuprum/rails/responders/html'
require 'cuprum/rails/responders/html/resource'

module Cuprum::Rails::Responders::Html
  # Defines default responses for a plural RESTful resource.
  #
  # - #create failure: renders the :new template.
  # - #create success: redirects to the resource #show page.
  # - #destroy success: redirects to the resource #index page.
  # - #index failure: redirects to the root path.
  # - #update failure: renders the :edit template.
  # - #update success: redirects to the resource #show page.
  #
  # Responds to any other successful result by rendering the template for the
  # action name and passing the result value as assigned variables. For a
  # failing result, redirects to either the show page or the index page for the
  # resource, based on the resource's defined #routes.
  class PluralResource < Cuprum::Rails::Responders::Html::Resource
    def initialize(**options)
      super

      SleepingKingStudios::Tools::CoreTools.deprecate(
        'Cuprum::Rails::Responders::Html::PluralResource',
        message: 'use Cuprum::Rails::Responders::Html::Resource'
      )
    end
  end
end
