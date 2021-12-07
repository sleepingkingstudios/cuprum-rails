# frozen_string_literal: true

class CreateBooks < ActiveRecord::Migration[6.0]
  def change
    create_table :books do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.string :title,  null: false, default: ''
      t.string :author, null: false, default: ''
      t.string :series
      t.string :category
    end
  end
end
