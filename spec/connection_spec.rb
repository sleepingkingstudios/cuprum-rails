# frozen_string_literal: true

require 'support/book'

RSpec.describe 'SQL connection' do # rubocop:disable RSpec/DescribeClass
  it { expect { Book.connection }.not_to raise_error }
end
