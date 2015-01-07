require 'spec_helper'

describe Rcqrs::Bus::EventBus do
  context "when publishing events" do
    before(:each) do
      @router = MockRouter.new
      @bus = Rcqrs::Bus::EventBus.new(@router)
      @bus.publish(Events::CompanyCreatedEvent.new)
    end

    it "should execute handler(s) for raised event" do
      expect(@router.handled).to be_truthy
    end
  end
end
