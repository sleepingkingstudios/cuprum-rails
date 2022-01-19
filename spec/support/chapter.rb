# frozen_string_literal: true

require 'active_record'

class Chapter < ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
  validates :title, presence: true
  validates :chapter_index,
    numericality: {
      greater_than_or_equal_to: 0,
      only_integer:             true
    },
    uniqueness:   { scope: :book_id }

  belongs_to :book

  # ActiveRecord automatically fails equality checks when id is nil.
  def ==(other)
    other.class == Chapter && other.attributes == attributes
  end
end
