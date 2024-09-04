# frozen_string_literal: true

require 'cuprum/rails'

require 'support/book'
require 'support/controllers/base_controller'
require 'support/middleware/logging_middleware'
require 'support/middleware/profiling_middleware'
require 'support/serializers/book_serializer'

class BooksController < BaseController
  class PublishCommand < Cuprum::Rails::Records::Command
    def initialize(record_class:, repository:, **)
      super(record_class:)

      @repository = repository
    end

    attr_reader :repository

    private

    def books_collection
      repository.find_or_create(entity_class: Book)
    end

    def parameters_contract
      Cuprum::Rails::Constraints::ParametersContract.new do
        key 'id', Stannum::Constraints::Presence.new
      end
    end

    def process(entity_id:)
      step { validate_parameters(entity_id:) }

      entity = step { books_collection.find_one.call(primary_key: entity_id) }

      entity.published_at = Time.zone.today

      books_collection.update_one.call(entity:)
    end

    def validate_parameters(entity_id:)
      match, errors = parameters_contract.match({ 'id' => entity_id })

      return success(nil) if match

      error = Cuprum::Rails::Errors::InvalidParameters.new(errors:)
      failure(error)
    end
  end

  def self.repository
    repository = super

    repository.find_or_create(entity_class: Book)

    repository
  end

  def self.resource # rubocop:disable Metrics/MethodLength
    @resource ||= Cuprum::Rails::Resource.new(
      default_order:        :id,
      entity_class:         Book,
      permitted_attributes: %i[
        title
        author
        series
        category
        published_at
      ]
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

  action :create,  Cuprum::Rails::Actions::Create,  member: false
  action :destroy, Cuprum::Rails::Actions::Destroy, member: true
  action :edit,    Cuprum::Rails::Actions::Edit,    member: true
  action :new,     Cuprum::Rails::Actions::New,     member: false
  action :index,   Cuprum::Rails::Actions::Index,   member: false
  action :show,    Cuprum::Rails::Actions::Show,    member: true
  action :update,  Cuprum::Rails::Actions::Update,  member: true

  action :publish, member: true do |repository:, request:, resource:, **|
    entity_id = request.params['id']
    entity    = step do
      PublishCommand
        .new(record_class: resource.entity_class, repository:)
        .call(entity_id:)
    end

    { 'book' => entity }
  end
end
