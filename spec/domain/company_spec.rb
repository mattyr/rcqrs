require 'spec_helper'

module Domain
  describe Company do
    context "when creating" do
      before(:each) do
        @company = Company.create('ACME Corp')
      end

      subject { @company }

      it "should set the company name" do
        expect(@company.name).to eq('ACME Corp')
      end

      it "should have a Events::CompanyCreatedEvent event" do
        expect(@company.pending_events.length).to eq(1)
        expect(@company.pending_events.last).to be_an_instance_of(Events::CompanyCreatedEvent)
      end

      specify { expect(@company.pending_events?).to be_truthy }
      specify { expect(@company.version).to eq(1) }
      specify { expect(@company.source_version).to eq(0) }
      specify { expect(@company.pending_events.length).to eq(1) }

      context "when commiting pending changes" do
        before(:each) do
          @company.commit
        end

        it "should have no pending changes" do
          expect(@company.pending_events?).to be_falsey
        end

        it "should have 0 pending events" do
          expect(@company.pending_events.length).to eq(0)
        end

        it "should update source version" do
          expect(@company.source_version).to eq(1)
        end

        specify { expect(@company.version).to eq(1) }
      end

      context "when adding an invoice" do
        before(:each) do
          @company.create_invoice("invoice-1", Time.now, "First invoice", 100)
        end

        it "should create a new invoice" do
          expect(@company.invoices.length).to eq(1)
        end

        it "should have a Events::InvoiceCreatedEvent event" do
          expect(@company.pending_events.length).to eq(2)
          expect(@company.pending_events.last).to be_an_instance_of(Events::InvoiceCreatedEvent)
        end
      end
    end

    context "when loading from events" do
      before(:each) do
        events = [
          Events::CompanyCreatedEvent.new(Rcqrs::Guid.create, 'ACME Corp'),
          Events::InvoiceCreatedEvent.new('1', Time.now, '', 100, 17.5),
          Events::InvoiceCreatedEvent.new('2', Time.now, '', 50, 17.5/2)
        ]
        events.each_with_index {|e, i| e.version = i + 1 }

        @company = Company.new
        @company.load(events)
      end

      subject { @company }
      specify { expect(@company.version).to eq(3) }
      specify { expect(@company.source_version).to eq(3) }
      specify { expect(@company.pending_events.length).to eq(0) }
      specify { expect(@company.replaying?).to be_falsey }

      it "should have created 2 invoices" do
        expect(@company.invoices.length).to eq(2)
      end
    end
  end
end
