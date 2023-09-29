# frozen_string_literal: true

require 'active_record'

class Cover < ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
  validates :artist, presence: true

  belongs_to :book

  # ActiveRecord automatically fails equality checks when id is nil.
  def ==(other)
    other.class == Cover && other.attributes == attributes
  end
end
