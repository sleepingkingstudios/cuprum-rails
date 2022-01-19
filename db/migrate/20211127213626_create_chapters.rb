# frozen_string_literal: true

class CreateChapters < ActiveRecord::Migration[6.1]
  def change
    create_table :chapters do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.string :title
      t.integer :chapter_index
    end

    add_reference :chapters, :book
  end
end
