# frozen_string_literal: true

require 'cuprum/rails/commands/resources/new'

require 'support/commands/books'

module Spec::Support::Commands::Books
  class New < Cuprum::Rails::Commands::Resources::New
    private

    def build_entity(attributes:)
      title      = attributes.fetch('title') { attributes.fetch(:title, '') }
      slug       = tools.string_tools.underscore(title).tr('_', '-')
      attributes = attributes.merge(slug:)

      super
    end
  end
end
