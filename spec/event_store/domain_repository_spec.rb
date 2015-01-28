require 'spec_helper'

describe Rcqrs::EventStore::DomainRepository do
  before(:each) do
    @command = spy
    Rcqrs::Context.current.command = @command
    @storage = Rcqrs::EventStore::Adapters::InMemoryAdapter.new
    @repository = Rcqrs::EventStore::DomainRepository.new(@storage)
    @aggregate = Domain::Company.create('ACME Corp.')
  end

  after { Rcqrs::Context.current.clear }

  context "when saving an aggregate" do
    before(:each) do
      @domain_event_raised = false
      @repository.on(:domain_event) {|event| @domain_event_raised = true }
      @repository.save(@aggregate)
    end

    it "should persist the aggregate's applied events" do
      expect(@storage.storage).to have_key(@aggregate.guid)
    end

    it "should raise domain event" do
      expect(@domain_event_raised).to be_truthy
    end

    it "should raise domain event on command in context" do
      expect(@command).to have_received(:broadcast_domain_event).once
    end
  end

  context "when saving an aggregate within a transaction" do
    before(:each) do
      @repository.transaction do
        expect(@repository.within_transaction?).to be_truthy
        @repository.save(@aggregate)
      end
    end

    it "should persist the aggregate's applied events" do
      expect(@storage.storage).to have_key(@aggregate.guid)
    end

    it "should not be within a transaction afterwards" do
      expect(@repository.within_transaction?).to be_falsey
    end
  end

  context "nested transactions" do
    it "remains in a transaction when leaving nested transaction scope" do
      @repository.transaction do
        expect(@repository.within_transaction?).to be_truthy
        @repository.save(@aggregate)
        @repository.transaction do
          expect(@repository.within_transaction?).to be_truthy
          @repository.save(@aggregate)
        end
        expect(@repository.within_transaction?).to be_truthy
      end
    end
  end

  context "when finding an aggregate that does not exist" do
    it "should raise an EventStore::AggregateNotFound exception" do
      expect(proc { @repository.find('missing') }).to raise_error(Rcqrs::EventStore::AggregateNotFound)
    end
  end

  context "when loading an aggregate" do
    before(:each) do
      @storage.save(@aggregate)
      @retrieved = @repository.find(@aggregate.guid)
    end

    subject { @retrieved }
    specify { expect(@retrieved).to be_instance_of(Domain::Company) }
    specify { expect(@retrieved.version).to eq(1) }
    specify { expect(@retrieved.pending_events.length).to eq(0) }
  end

  context "when reloading same aggregate" do
    before(:each) do
      @storage.save(@aggregate)
      @mock_storage = double
      @repository = Rcqrs::EventStore::DomainRepository.new(@mock_storage)
      expect(@mock_storage).to receive(:find).with(@aggregate.guid).once { @storage.find(@aggregate.guid) }
    end

    it "should only retrieve aggregate once" do
      @repository.find(@aggregate.guid)
      @repository.find(@aggregate.guid)
    end
  end
end
