# frozen_string_literal: true

class AddTimestampsToTomes < ActiveRecord::Migration[7.0]
  def change
    change_table :tomes do |t| # rubocop:disable Style/SymbolProc
      t.timestamps
    end
  end
end
