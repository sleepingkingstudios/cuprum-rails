# frozen_string_literal: true

require 'cuprum/rails'
require 'cuprum/rails/controller_action'
require 'cuprum/rails/controllers/class_methods/configuration'
require 'cuprum/rails/controllers/class_methods/validations'

module Cuprum::Rails
  # Provides a DSL for defining actions and responses.
  #
  # @example Defining A Controller
  #   class ExampleController < ApplicationController
  #     include Cuprum::Rails::Controller
  #
  #     responder :html, CustomHtmlResponder
  #
  #     action :process, ExampleProcessAction
  #   end
  #
  # @example Defining A RESTful Controller
  #   class BooksController
  #     include Cuprum::Rails::Controller
  #
  #     responder :html, Cuprum::Rails::Responders::Html::PluralResource
  #
  #     action :index,     Cuprum::Rails::Actions::Index
  #     action :show,      Cuprum::Rails::Actions::Show, member: true
  #     action :published, Books::Published
  #     action :publish,   Books::Publish,               member: true
  #   end
  module Controller
    # Exception when the controller does not define a resource.
    class UndefinedResourceError < StandardError; end

    # Exception when the controller does not have a responder for a format.
    class UnknownFormatError < StandardError; end

    class << self
      private

      def included(other)
        super

        other.extend(Cuprum::Rails::Controllers::ClassMethods::Actions)
        other.extend(Cuprum::Rails::Controllers::ClassMethods::Configuration)
        other.extend(Cuprum::Rails::Controllers::ClassMethods::Validations)
      end
    end
  end
end
