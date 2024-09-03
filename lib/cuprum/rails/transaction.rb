# frozen_string_literal: true

require 'cuprum/errors/uncaught_exception'
require 'cuprum/rails'

module Cuprum::Rails
  # Command encapsulating a database transaction.
  #
  # Wraps the block in an ActiveRecord transaction. If the block returns a
  # failing result or raises an exception, the transaction is rolled back.
  #
  # @example
  #   result = Cuprum::Rails::Transaction.new.call do
  #     Book.create(title: 'Gideon the Ninth', author: 'Tammsyn Muir')
  #
  #     success({ ok: true })
  #   end
  #   result.success? #=> true
  #   result.value    #=> { ok: true }
  #   Book.where(title: 'Gideon the Ninth').exists?
  #   #=> true
  #
  #   result = Cuprum::Rails::Transaction.new.call do
  #     Book.create(title: 'Harrow the Ninth', author: 'Tammsyn Muir')
  #
  #     error = Cuprum::Error.new(message: 'Something went wrong')
  #     failure(error)
  #   end
  #   result.success?      #=> false
  #   result.error.message #=> 'Something went wrong'
  #   Book.where(title: 'Harrow the Ninth').exists?
  #   #=> false
  class Transaction < Cuprum::Command
    private

    def process(&block) # rubocop:disable Metrics/MethodLength
      result = nil

      ActiveRecord::Base.transaction do
        begin
          result = steps(&block)
        rescue StandardError => exception
          error = Cuprum::Errors::UncaughtException.new(
            exception:,
            message:   'uncaught exception in transaction -'
          )
          result = failure(error)
        end

        raise ActiveRecord::Rollback if result.failure?
      end

      result
    end
  end
end
