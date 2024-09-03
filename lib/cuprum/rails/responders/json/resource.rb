# frozen_string_literal: true

require 'cuprum/collections/errors/already_exists'
require 'cuprum/collections/errors/extra_attributes'
require 'cuprum/collections/errors/failed_validation'
require 'cuprum/collections/errors/not_found'

require 'cuprum/rails/errors/invalid_parameters'
require 'cuprum/rails/responders/json'
require 'cuprum/rails/responders/json_responder'

module Cuprum::Rails::Responders::Json
  # Defines default responses for a RESTful resource.
  #
  # - #create success: serializes the data with status 201 Created.
  # - failure AlreadyExists: serializes the error with status 422 Unprocessable
  #     Entity.
  # - failure ExtraAttributes: serializes the error with status 422
  #     Unprocessable Entity.
  # - failure FailedValidation: serializes the error with status 422
  #     Unprocessable Entity.
  # - failure InvalidParameters: serializes the error with status 400 Bad
  #     Request.
  # - failure NotFound: serializes the error with status 404 Not Found.
  #
  # Responds to any other successful result by serializing the result value with
  # status 200. For a failing result, serializes a generic error with status
  # 500 Internal Server Error.
  class Resource < Cuprum::Rails::Responders::JsonResponder
    action :create do
      match :success do |result|
        render_success(result.value, status: 201)
      end
    end

    match :failure, error: Cuprum::Collections::Errors::AlreadyExists \
    do |result|
      render_failure(result.error, status: 422)
    end

    match :failure, error: Cuprum::Collections::Errors::ExtraAttributes \
    do |result|
      render_failure(result.error, status: 422)
    end

    match :failure, error: Cuprum::Collections::Errors::FailedValidation \
    do |result|
      render_failure(result.error, status: 422)
    end

    match :failure, error: Cuprum::Collections::Errors::NotFound \
    do |result|
      render_failure(result.error, status: 404)
    end

    match :failure, error: Cuprum::Rails::Errors::InvalidParameters do |result|
      render_failure(result.error, status: 400)
    end
  end
end
