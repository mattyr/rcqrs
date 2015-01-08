require 'spec_helper'

describe Rcqrs::Command::ScheduledCommandJob do
  let(:command) { Commands::CreateCompanyCommand.new(name: 'Delayed!') }
    it "does not raise an error" do
      expect( -> { Rcqrs::Command::ScheduledCommandJob.perform_later('fake', command.class.name, command.attributes) } ).to_not raise_error
    end

  context "performing immediately" do
    before do
      Rcqrs::Command::ScheduledCommandJob.perform_later('fake', command.class.name, command.attributes)
    end

    it "gets worked off immediately" do
      expect(Delayed::Job.count).to eq(1)
      Delayed::Worker.new.work_off
      expect(Delayed::Job.count).to eq(0)
    end
  end

  context "delayed" do
    before do
      Rcqrs::Command::ScheduledCommandJob.set(wait_until: 1.day.from_now).
        perform_later('fake', command.class.name, command.attributes)
    end

    it "does not get worked off immediately" do
      Delayed::Worker.new.work_off
      expect(Delayed::Job.count).to eq(1)
    end

    it "gets worked off after delay" do
      Timecop.travel(2.days.from_now) do
        Delayed::Worker.new.work_off
        expect(Delayed::Job.count).to eq(0)
      end
    end
  end
end
