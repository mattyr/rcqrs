require 'spec_helper'

describe Rcqrs::Gateway do
  before(:each) do
    # HACK (see spec/event_store/active_record_adapter_spec.rb)
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
    Rcqrs::Gateway.config.event_store_adapter =
      Rcqrs::EventStore::Adapters::ActiveRecordAdapter.new(adapter: 'sqlite3', database: ':memory:')
  end

  it "should trigger domain class's event handlers" do
    expect_any_instance_of(Domain::Company).to receive(:on_company_created).once.and_call_original
    command = Commands::CreateCompanyCommand.new(name: 'ACME corp')
    Rcqrs::Gateway.publish(command)
  end

  context "after processing commands" do
    before do
      allow(Rcqrs::Context.current).to receive(:command=).and_call_original
      allow(Rcqrs::Context.current).to receive(:clear).and_call_original
      Reporting::Company.instances = []
      @command = Commands::CreateCompanyCommand.new(name: 'ACME corp')
      Rcqrs::Gateway.publish(@command)
    end

    it "should update the event store" do
      expect(Rcqrs::EventStore::Adapters::EventProvider.count).to eq(1)
      expect(Rcqrs::EventStore::Adapters::Event.count).to eq(1)
    end

    it "should have triggered event handlers" do
      expect(Reporting::Company.instances.length).to eq(1)
    end

    it "should set and then clear the current command context" do
      expect(Rcqrs::Context.current).to have_received(:command=).with(@command)
      expect(Rcqrs::Context.current).to have_received(:command=).with(nil)
      expect(Rcqrs::Context.current).to have_received(:clear)
    end
  end
end
