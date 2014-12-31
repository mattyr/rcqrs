require 'spec_helper'

module Bus
  describe CommandBus do
    context "when dispatching commands" do
      before(:each) do
        @router = MockRouter.new
        @bus = CommandBus.new(@router, nil)
      end

      context "invalid command" do
        subject { Commands::CreateCompanyCommand.new }

        it "should raise an InvalidCommand exception when the command is invalid" do
          expect(proc { @bus.dispatch(subject) }).to raise_error(Commands::InvalidCommand)
          expect(subject.errors[:name]).to eq(["can't be blank"])
        end
      end

      context "valid command" do
        subject { Commands::CreateCompanyCommand.new('foo') }

        it "should execute handler for given command" do
          @bus.dispatch(subject)
          expect(@router.handled).to be_truthy
        end
      end
    end
  end
end
