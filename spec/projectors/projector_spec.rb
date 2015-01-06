require 'spec_helper'

module Projectors
  describe ReportingProjector do
    let(:projector) { Projectors::Registry.projectors.first }
    let(:event) { Events::CompanyCreatedEvent.new(guid: 'test', name: 'Acme Corp') }
    before { Reporting::Company.instances.clear }
    before { allow(projector).to receive(:on_company_created).and_call_original }

    shared_examples_for "a successful projection" do
      let(:company) { Reporting::Company.instances.first }
      specify { expect(company.guid).to eq(event.guid) }
      specify { expect(company.name).to eq(event.name) }
    end

    context "project called with event" do
      before do
        projector.project(event)
      end

      it "should call a handler function" do
        expect(projector).to have_received(:on_company_created).once
      end

      it_behaves_like "a successful projection"
    end

    it "does not raise error for ignored events" do
      expect( -> {projector.project(Events::InvoiceCreatedEvent.new) }).to_not raise_error
    end

    context "published on event bus" do
      before { Bus::EventBus.new(MockRouter.new).publish(event) }

      it "should invoke the projector" do
        expect(projector).to have_received(:on_company_created).once
      end

      it_behaves_like "a successful projection"
    end
  end
end
