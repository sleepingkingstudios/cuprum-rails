# frozen_string_literal: true

require 'active_record'

class Book < ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
  validates :title,  presence: true
  validates :author, presence: true

  has_one  :cover
  has_many :chapters

  # ActiveRecord automatically fails equality checks when id is nil.
  def ==(other)
    other.class == Book && other.attributes == attributes
  end
end
