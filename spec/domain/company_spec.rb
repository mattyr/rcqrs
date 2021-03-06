require File.join(File.dirname(__FILE__), '../spec_helper')

module Domain
  describe Company do
    context "when creating" do
      before(:each) do
        @company = Company.create('ACME Corp')
      end
    
      subject { @company }
      
      it "should set the company name" do
        @company.name.should == 'ACME Corp'
      end

      it "should have a Events::CompanyCreatedEvent event" do
        @company.pending_events.length.should == 1
        @company.pending_events.last.should be_an_instance_of(Events::CompanyCreatedEvent)
      end
      
      specify { @company.pending_events?.should == true }
      specify { @company.version.should == 1 }
      specify { @company.source_version.should == 0 }
      specify { @company.pending_events.length.should == 1 }
      
      context "when commiting pending changes" do
        before(:each) do
          @company.commit
        end
        
        it "should have no pending changes" do
          @company.pending_events?.should == false
        end
        
        it "should have 0 pending events" do
          @company.pending_events.length.should == 0
        end
        
        it "should update source version" do
          @company.source_version.should == 1
        end
        
        specify { @company.version.should == 1 }
      end
      
      context "when adding an invoice" do
        before(:each) do
          @company.create_invoice("invoice-1", Time.now, "First invoice", 100)
        end
        
        it "should create a new invoice" do
          @company.invoices.length.should == 1
        end
        
        it "should have a Events::InvoiceCreatedEvent event" do
          @company.pending_events.length.should == 2
          @company.pending_events.last.should be_an_instance_of(Events::InvoiceCreatedEvent)
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
      specify { @company.version.should == 3 }
      specify { @company.source_version.should == 3 }
      specify { @company.pending_events.length.should == 0 }
      specify { @company.replaying?.should == false }
      
      it "should have created 2 invoices" do
        @company.invoices.length.should == 2
      end
    end
  end
end