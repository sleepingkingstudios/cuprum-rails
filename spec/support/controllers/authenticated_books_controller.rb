# frozen_string_literal: true

require 'support/controllers/books_controller'
require 'support/middleware/session_middleware'

class AuthenticatedBooksController < BooksController
  middleware Spec::Support::Middleware::SessionMiddleware
end
