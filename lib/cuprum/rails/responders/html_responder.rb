# frozen_string_literal: true

require 'cuprum/rails/responses/html/redirect_response'
require 'cuprum/rails/responders'
require 'cuprum/rails/responders/actions'
require 'cuprum/rails/responders/base_responder'
require 'cuprum/rails/responders/html/rendering'
require 'cuprum/rails/responders/matching'

module Cuprum::Rails::Responders
  # Provides a DSL for defining responses to HTML requests.
  #
  # By default, responds to any successful result by rendering the template for
  # the action name and passing the result value as assigned variables. For a
  # failing result, redirects to either the show page or the index page for the
  # resource, based on the resource's defined #routes.
  #
  # @example Defining A Response
  #   class CustomResponder < Cuprum::Rails::Responders::HtmlResponder
  #     match :failure, error: Spec::AuthorizationError do
  #       redirect_to('/login')
  #     end
  #   end
  #
  # @example Defining Responses For An Action
  #   class ActionsResponder < Cuprum::Rails::Responders::HtmlResponder
  #     action :publish do
  #       match :failure do
  #         redirect_to(resource.routes.index_path)
  #       end
  #
  #       match :success do
  #         redirect_to(resource.routes.show_path(@result.value))
  #       end
  #     end
  #   end
  #
  # @see Cuprum::Rails::Responders::Actions::ClassMethods#action
  # @see Cuprum::Rails::Responders::Matching::ClassMethods#match
  class HtmlResponder < BaseResponder
    include Cuprum::Rails::Responders::Html::Rendering
    include Cuprum::Rails::Responders::Matching
    include Cuprum::Rails::Responders::Actions

    match :success do
      render action_name
    end

    match :failure do
      next redirect_to(resource.base_path) unless resource.routes

      path = resource_path(result) || resource.routes.index_path

      redirect_to(path)
    end

    # @!method call(result)
    #   (see Cuprum::Rails::Responders::Actions#call)

    # @return [Symbol] the format of the responder.
    def format
      :html
    end

    private

    def resource_entity
      if result.value.is_a?(Hash)
        result.value[resource.singular_name]
      else
        result.value
      end
    end

    def resource_path(result)
      return routes.index_path if result.value.nil?

      entity = resource_entity

      return routes.show_path(entity) if entity

      routes.index_path
    end
  end
end
