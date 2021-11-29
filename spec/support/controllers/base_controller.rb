# frozen_string_literal: true

require 'forwardable'

require 'cuprum/rails'

class BaseController
  extend  Forwardable
  include Cuprum::Rails::Controller

  responder :html, Cuprum::Rails::Responders::Html::PluralResource
  responder :json, Cuprum::Rails::Responders::Json::Resource

  def self.repository
    Cuprum::Rails::Repository.new
  end

  def initialize(renderer:, request:)
    @renderer = renderer
    @request  = request
  end

  attr_reader :request

  def_delegators :@renderer,
    :redirect_to,
    :render

  def assigns
    @assigns ||= {}
  end

  def instance_variable_set(variable, value)
    assigns[variable] = value

    super
  end
end
