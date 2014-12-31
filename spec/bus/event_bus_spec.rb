require 'spec_helper'

module Bus
  describe EventBus do
    context "when publishing events" do
      before(:each) do
        @router = MockRouter.new
        @bus = EventBus.new(@router)
        @bus.publish(Events::CompanyCreatedEvent.new)
      end

      it "should execute handler(s) for raised event" do
        expect(@router.handled).to be_truthy
      end
    end
  end
end
