require 'spec_helper'

module Events
  describe CompanyCreatedEvent do
    context "serialization" do
      before(:each) do
        @event = CompanyCreatedEvent.new(guid: Rcqrs::Guid.create, name: 'ACME Corp')
      end

      it "should serialize to json" do
        json = @event.to_json
        expect(json.length).to be > 0
      end

      it "should deserialize from json" do
        deserialized = CompanyCreatedEvent.new.from_json(@event.to_json)

        expect(deserialized.name).to eq(@event.name)
        expect(deserialized.guid).to eq(@event.guid)
      end
    end

    it "should have an appropriate target name" do
      expect(CompanyCreatedEvent.target_name).to eq("company_created")
    end
  end
end
