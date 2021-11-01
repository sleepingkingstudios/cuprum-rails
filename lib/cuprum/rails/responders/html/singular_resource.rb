# frozen_string_literal: true

require 'cuprum/collections/errors/failed_validation'

require 'cuprum/rails/responders/html'
require 'cuprum/rails/responders/html_responder'

module Cuprum::Rails::Responders::Html
  # @todo
  class SingularResource < Cuprum::Rails::Responders::HtmlResponder
    # Singular resource actions:
    # - POST   /book (create)
    #   - success: redirect to /book
    #   - failure (Validation): render :new
    # - DELETE /book (destroy)
    #   - success: redirect to root resource
    # - GET    /book/edit (edit)
    # - GET    /book/new (new)
    # - GET    /book (show)
    # - PATCH  /book (update)
    #   - success: redirect to /book
    #   - failure (Validation): render :edit
    #
    # - generic action
    #   - failure: entity ? redirect to /book : redirect to root resource
    action :create do
      match :failure, error: Cuprum::Collections::Errors::FailedValidation do
        render :new,
          assigns: result.value.merge(errors: result.error.errors),
          status:  422 # rubocop:disable Rails/HttpStatus
      end

      match :success do
        redirect_to resource.routes.show_path
      end
    end

    action :destroy do
      match :success do
        next redirect_to(resource.base_path) unless resource.routes

        redirect_to(resource.routes.parent_path)
      end
    end

    action :update do
      match :failure, error: Cuprum::Collections::Errors::FailedValidation do
        render :edit,
          assigns: result.value.merge(errors: result.error.errors),
          status:  422 # rubocop:disable Rails/HttpStatus
      end

      match :success do
        redirect_to resource.routes.show_path
      end
    end

    match :failure do
      next redirect_to(resource.base_path) unless resource.routes

      redirect_to(resource.routes.parent_path)
    end
  end
end
