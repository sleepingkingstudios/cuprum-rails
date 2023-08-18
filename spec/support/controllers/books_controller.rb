# frozen_string_literal: true

require 'cuprum/rails'

require 'support/book'
require 'support/controllers/base_controller'
require 'support/middleware/logging_middleware'
require 'support/middleware/profiling_middleware'
require 'support/serializers/book_serializer'

class BooksController < BaseController
  def self.repository
    repository = super

    repository.find_or_create(entity_class: Book)

    repository
  end

  def self.resource
    @resource ||= Cuprum::Rails::Resource.new(
      permitted_attributes: %i[title author series category published_at],
      resource_class:       Book
    )
  end

  def self.serializers
    super.merge(
      Book => Spec::Support::Serializers::BookSerializer
    )
  end

  middleware Spec::Support::Middleware::LoggingMiddleware,
    only: %i[create destroy update]
  middleware Spec::Support::Middleware::ProfilingMiddleware

  action :create,  Cuprum::Rails::Actions::Create
  action :destroy, Cuprum::Rails::Actions::Destroy
  action :edit,    Cuprum::Rails::Actions::Edit
  action :new,     Cuprum::Rails::Actions::New
  action :index,   Cuprum::Rails::Actions::Index
  action :show,    Cuprum::Rails::Actions::Show
  action :update,  Cuprum::Rails::Actions::Update
end
