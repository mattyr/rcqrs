require 'spec_helper'

module Events
  module Handlers
    describe CompanyCreatedHandler do
      before(:each) do
        @handler = CompanyCreatedHandler.new
      end

      context "when executing" do
        before(:each) do
          @event = Events::CompanyCreatedEvent.new(:guid => Rcqrs::Guid.create, :name => 'ACME corp')
          @company = @handler.execute(@event)
        end

        specify { expect(@company).to be_instance_of(Reporting::Company) }
        specify { expect(@company.guid).to eq(@event.guid) }
        specify { expect(@company.name).to eq(@event.name) }
      end
    end
  end
end
