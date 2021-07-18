# frozen_string_literal: true

require 'active_model'

class Publisher
  include ActiveModel::Model

  def self.primary_key
    :id
  end

  attr_accessor :id

  def [](value)
    send(value)
  end
end
