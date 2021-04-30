# frozen_string_literal: true

require 'active_record'

class Book < ActiveRecord::Base
  validates :title,  presence: true
  validates :author, presence: true

  # ActiveRecord automatically fails equality checks when id is nil.
  def ==(other)
    other.class == Book && other.attributes == attributes
  end
end
