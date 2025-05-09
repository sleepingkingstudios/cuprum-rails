# frozen_string_literal: true

require 'cuprum/rails/commands/resources/create'

require 'support/commands/books'

module Spec::Support::Commands::Books
  class Edit < Cuprum::Rails::Commands::Resources::Edit
    private

    def update_entity(attributes:, entity:)
      title      = attributes.fetch('title') { attributes.fetch(:title, '') }
      slug       = tools.string_tools.underscore(title).tr('_', '-')
      attributes = attributes.merge(slug:)

      super
    end
  end
end
