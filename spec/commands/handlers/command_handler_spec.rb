require 'spec_helper'

module Commands
  module Handlers
    describe CreateCompanyHandler do
      before(:each) do
        @repository = double
        @handler = CreateCompanyHandler.new(@repository)
      end

      context "when executing command" do
        before(:each) do
          expect(@repository).to receive(:save) {|company| @company = company }
          @command = Commands::CreateCompanyCommand.new(:name => 'ACME corp')
          @handler.execute(@command)
        end

        specify { expect(@company).to be_instance_of(Domain::Company) }
        specify { expect(@company.name).to eq(@command.name) }
      end
    end
  end
end
