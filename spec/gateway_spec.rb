require 'spec_helper'

describe Rcqrs::Gateway do
  before(:each) do
    # HACK (see spec/event_store/active_record_adapter_spec.rb)
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
    Rcqrs::Gateway.config.event_store_adapter =
      EventStore::Adapters::ActiveRecordAdapter.new(adapter: 'sqlite3', database: ':memory:')
  end

  it "should trigger domain class's event handlers" do
    expect_any_instance_of(Domain::Company).to receive(:on_company_created).once.and_call_original
    command = Commands::CreateCompanyCommand.new(name: 'ACME corp')
    Rcqrs::Gateway.publish(command)
  end

  context "after processing commands" do
    before do
      Reporting::Company.instances = []
      command = Commands::CreateCompanyCommand.new(name: 'ACME corp')
      Rcqrs::Gateway.publish(command)
    end

    it "should update the event store" do
      expect(EventStore::Adapters::EventProvider.count).to eq(1)
      expect(EventStore::Adapters::Event.count).to eq(1)
    end

    it "should have triggered event handlers" do
      expect(Reporting::Company.instances.length).to eq(1)
    end
  end
end
