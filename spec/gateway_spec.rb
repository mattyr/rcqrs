require 'spec_helper'

describe Rcqrs::Gateway do
  let(:create_command) { Commands::CreateCompanyCommand.new(name: 'ACME corp') }
  before(:each) { Reporting::Company.instances.clear }

  it "should trigger domain class's event handlers" do
    expect_any_instance_of(Domain::Company).to receive(:on_company_created).once.and_call_original
    Rcqrs::Gateway.publish(create_command)
  end

  context "after processing commands" do
    before do
      allow(Rcqrs::Context.current).to receive(:command=).and_call_original
      allow(Rcqrs::Context.current).to receive(:clear).and_call_original
      Reporting::Company.instances = []
      Rcqrs::Gateway.publish(create_command)
    end

    it "should update the event store" do
      # query in-memory store
      expect(Rcqrs::Gateway.repository.event_store.storage.length).to eq(1)
      expect(Rcqrs::Gateway.repository.event_store.storage.values.first.events.length).to eq(1)
    end

    it "should have triggered event handlers" do
      expect(Reporting::Company.instances.length).to eq(1)
    end

    it "should set and then clear the current command context" do
      expect(Rcqrs::Context.current).to have_received(:command=).with(create_command)
      expect(Rcqrs::Context.current).to have_received(:command=).with(nil)
      expect(Rcqrs::Context.current).to have_received(:clear)
    end
  end

  context "delayed commands" do
    let(:company_id) { Reporting::Company.instances.first.guid }
    let(:change_command) do
      Commands::ChangeCompanyNameCommand.new(company_id: company_id, name: "All New Acme Corp")
    end

    before do
      Rcqrs::Gateway.publish(create_command)
      Rcqrs::Gateway.publish_at(change_command.company_id, change_command, DateTime.now + 3.days)
    end

    it "should not initially perform the command" do
      Delayed::Worker.new.work_off
      expect(Delayed::Job.count).to eq(1)
    end

    it "should create a command scheduled event" do
      last_event =
        Rcqrs::Gateway.repository.event_store.storage.values.first.events.last
      expect(last_event.event_type.constantize).to eq(Rcqrs::Event::CommandScheduled)
    end

    it "should add to the aggregate's pending commands" do
      aggregate = Rcqrs::Gateway.repository.find(company_id)
      expect(aggregate.pending_commands.length).to eq(1)
    end

    context "after time has passed" do
      before do
        Timecop.travel(4.days.from_now)
        Delayed::Worker.new.work_off
      end
      after { Timecop.return }

      it "should perform the command" do
        expect(Delayed::Job.count).to eq(0)
      end

      it "should no longer be in aggregate's pending commands" do
        aggregate = Rcqrs::Gateway.repository.find(company_id)
        expect(aggregate.pending_commands.length).to eq(0)
      end
    end
  end
end
