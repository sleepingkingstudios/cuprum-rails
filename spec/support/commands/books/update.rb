# frozen_string_literal: true

require 'cuprum/rails/commands/resources/update'

require 'support/commands/books'

module Spec::Support::Commands::Books
  class Update < Cuprum::Rails::Commands::Resources::Update
    private

    def update_entity(attributes:, entity:)
      title      = attributes.fetch('title') { attributes.fetch(:title, '') }
      slug       = tools.string_tools.underscore(title).tr('_', '-')
      attributes = attributes.merge(slug:)

      super
    end
  end
end
