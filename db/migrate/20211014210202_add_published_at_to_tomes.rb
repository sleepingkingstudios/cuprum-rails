# frozen_string_literal: true

class AddPublishedAtToTomes < ActiveRecord::Migration[6.0]
  def change
    add_column :tomes, :published_at, :datetime
  end
end
