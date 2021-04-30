# frozen_string_literal: true

RSpec.describe 'SQL connection' do # rubocop:disable RSpec/DescribeClass
  it { expect { ActiveRecord::Base.connection }.not_to raise_error }
end
