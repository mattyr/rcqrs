require 'bundler/setup'
Bundler.setup

require 'rcqrs'
require 'delayed_job_active_record'
require 'timecop'

require 'mock_router'
require 'commands/create_company_command'
require 'commands/handlers/create_company_handler'
require 'commands/change_company_name_command'
require 'commands/handlers/change_company_name_handler'
require 'events/company_created_event'
require 'events/invoice_created_event'
require 'events/handlers/company_created_handler'
require 'events/company_name_changed_event'
require 'events/handlers/company_name_changed_handler'
require 'domain/invoice'
require 'domain/company'
require 'projectors/reporting_projector'
require 'reporting/company'

TEST_DB_CONFIG = {
  adapter: 'sqlite3',
  database: ':memory:'
}

# setup for delayed job
ActiveRecord::Migration.verbose = false
require File.join(Gem::Specification.find_by_name("delayed_job_active_record").gem_dir, "/lib/generators/delayed_job/templates/migration.rb")
ActiveJob::Base.queue_adapter = :delayed_job
ActiveJob::Base.logger = nil

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:all) do
    ActiveRecord::Base.establish_connection(TEST_DB_CONFIG)
    CreateDelayedJobs.up
  end

  config.around(:each) do |example|
    Rcqrs::Gateway.reinitialize
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
