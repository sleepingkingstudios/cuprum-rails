# frozen_string_literal: true

require 'active_record'

class Tome < ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
  self.primary_key = :uuid

  validates :title,  presence: true
  validates :author, presence: true

  # ActiveRecord automatically fails equality checks when id is nil.
  def ==(other)
    # :nocov:
    other.class == Tome && other.attributes == attributes
    # :nocov:
  end

  def inspect
    "#<Tome uuid: #{uuid.inspect}>"
  end
end
