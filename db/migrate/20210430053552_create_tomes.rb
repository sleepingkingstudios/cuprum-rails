# frozen_string_literal: true

class CreateTomes < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :tomes, id: false do |t|
      t.uuid   :uuid,   null: false
      t.string :title,  null: false, default: ''
      t.string :author, null: false, default: ''
      t.string :series
      t.string :category
    end

    add_index :tomes, :uuid, unique: true
  end
end
