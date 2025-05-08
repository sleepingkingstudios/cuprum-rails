# frozen_string_literal: true

require 'cuprum/rails/commands/resources/create'

require 'support/commands/books'

module Spec::Support::Commands::Books
  class Create < Cuprum::Rails::Commands::Resources::Create
    private

    def build_entity(attributes:)
      title      = attributes.fetch('title') { attributes.fetch(:title, '') }
      slug       = tools.string_tools.underscore(title).tr('_', '-')
      attributes = attributes.merge(slug:)

      super
    end
  end
end
