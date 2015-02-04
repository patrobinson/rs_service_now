require 'rs_service_now'
require 'rspec/mocks'
require 'helpers'

RSpec.configure do |config|
  config.include ServiceNowHelpers
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end