# frozen_string_literal: true

require 'cuprum/collections/errors/failed_validation'

require 'cuprum/rails/responders/html'

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
  class PluralResource < Cuprum::Rails::Responders::HtmlResponder
    include Cuprum::Rails::Responders::Matching
    include Cuprum::Rails::Responders::Actions

    action :create do
      match :failure, error: Cuprum::Collections::Errors::FailedValidation do
        render :new,
          assigns: result.value.merge(errors: result.error.errors),
          status:  422 # rubocop:disable Rails/HttpStatus
      end

      match :success do
        entity = result.value[resource.singular_resource_name]

        redirect_to resource.routes.show_path(entity)
      end
    end

    action :destroy do
      match :success do
        redirect_to resource.routes.index_path
      end
    end

    action :index do
      match :failure do
        redirect_to resource.routes.root_path
      end
    end

    action :update do
      match :failure, error: Cuprum::Collections::Errors::FailedValidation do
        render :edit,
          assigns: result.value.merge(errors: result.error.errors),
          status:  422 # rubocop:disable Rails/HttpStatus
      end

      match :success do
        entity = result.value[resource.singular_resource_name]

        redirect_to resource.routes.show_path(entity)
      end
    end
  end
end
