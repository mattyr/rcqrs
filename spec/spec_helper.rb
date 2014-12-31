require 'bundler/setup'
Bundler.setup

require 'rcqrs'

require 'mock_router'
require 'commands/create_company_command'
require 'commands/handlers/create_company_handler'
require 'events/company_created_event'
require 'events/invoice_created_event'
require 'events/handlers/company_created_handler'
require 'domain/invoice'
require 'domain/company'
require 'reporting/company'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
