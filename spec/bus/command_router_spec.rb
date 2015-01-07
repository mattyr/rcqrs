require 'spec_helper'

describe Rcqrs::Bus::CommandRouter do
  context "when getting handler for commands" do
    before(:each) do
      @router = Rcqrs::Bus::CommandRouter.new
      @repository = double
    end

    it "should raise a Bus::MissingHandler exception when no command handler is found" do
      expect(proc { @router.handler_for(nil, @repository) }).to raise_error(Rcqrs::Bus::MissingHandler)
    end

    it "should find the corresponding handler for a command" do
      command = Commands::CreateCompanyCommand.new
      handler = @router.handler_for(command, @repository)
      expect(handler).to be_instance_of(Commands::Handlers::CreateCompanyHandler)
    end
  end
end
