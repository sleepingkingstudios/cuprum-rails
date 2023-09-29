# frozen_string_literal: true

class CreateCovers < ActiveRecord::Migration[6.0]
  def change
    create_table :covers do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.string :artist
    end

    add_reference :covers, :book
  end
end
