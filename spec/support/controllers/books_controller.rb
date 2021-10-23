# frozen_string_literal: true

require 'cuprum/rails'

require 'support/book'
require 'support/controllers/base_controller'

class BooksController < BaseController
  action :create,  Cuprum::Rails::Actions::Create
  action :destroy, Cuprum::Rails::Actions::Destroy
  action :edit,    Cuprum::Rails::Actions::Show
  action :new,     Cuprum::Rails::Actions::New
  action :index,   Cuprum::Rails::Actions::Index
  action :show,    Cuprum::Rails::Actions::Show
  action :update,  Cuprum::Rails::Actions::Update

  private

  def resource
    @resource ||= Cuprum::Rails::Resource.new(
      collection:           Cuprum::Rails::Collection.new(record_class: Book),
      permitted_attributes: %i[title author series category published_at],
      resource_class:       Book
    )
  end
end
