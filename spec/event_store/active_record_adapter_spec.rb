require 'spec_helper'

describe Rcqrs::EventStore::Adapters::ActiveRecordAdapter do
  before(:each) do
    # HACK? it seems some operations in AR need AR::Base to determine
    # things like column names. without this we get errors like "no
    # connection pool for ActiveRecord::Base".  This could be a bug or an
    # architectural issue with AR connection management.
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
    # Use an in-memory sqlite db
    @adapter = Rcqrs::EventStore::Adapters::ActiveRecordAdapter.new(:adapter => 'sqlite3', :database => ':memory:')
    @aggregate = Domain::Company.create('ACME Corp')
  end

  context "when saving events" do
    before(:each) do
      @adapter.save(@aggregate)
      @provider = @adapter.find(@aggregate.guid)
    end

    it "should persist a single event provider (aggregate)" do
      count = @adapter.provider_connection.select_value('select count(*) from event_providers').to_i
      expect(count).to eq(1)
    end

    it "should persist a single event" do
      count = @adapter.event_connection.select_value('select count(*) from events').to_i
      expect(count).to eq(1)
    end

    specify { expect(@provider.aggregate_type).to eq('Domain::Company') }
    specify { expect(@provider.aggregate_id).to eq(@aggregate.guid) }
    specify { expect(@provider.version).to eq(1) }
    specify { expect(@provider.events.count).to eq(1) }

    context "persisted event" do
      before(:each) do
        @event = @provider.events.first
      end

      specify { expect(@event.aggregate_id).to eq(@aggregate.guid) }
      specify { expect(@event.event_type).to eq('Events::CompanyCreatedEvent') }
      specify { expect(@event.version).to eq(1) }
    end
  end

  context "when saving incorrect aggregate version" do
    before(:each) do
      @adapter.save(@aggregate)
    end

    it "should raise AggregateConcurrencyError exception" do
      expect(proc { @adapter.save(@aggregate) }).to raise_error(Rcqrs::EventStore::AggregateConcurrencyError)
    end
  end

  context "when finding events" do
    it "should return nil when aggregate not found" do
      expect(@adapter.find('')).to be_nil
    end
  end

  context "when saving aggregate within a transaction" do
    before (:each) do
      begin
        @adapter.transaction do
          @adapter.save(@aggregate)
          expect(event_provider_count).to eq(1)
          expect(event_count).to eq(1)

          raise 'rollback'
        end
      rescue
        # expected rollback exception
      end
    end

    def event_provider_count
      #@adapter.provider_connection.select_value('select count(*) from event_providers').to_i
      Rcqrs::EventStore::Adapters::EventProvider.count
    end

    def event_count
      #@adapter.event_connection.select_value('select count(*) from events').to_i
      Rcqrs::EventStore::Adapters::Event.count
    end

    it "should rollback saved event provider" do
      expect(event_provider_count).to eq(0)
    end

    it "should rollback saved events" do
      expect(event_count).to eq(0)
    end
  end
end
