module Domain
  class Company
    include Rcqrs::Domain::AggregateRoot

    attr_reader :name
    attr_reader :invoices

    def self.create(name)
      event = Events::CompanyCreatedEvent.new(:guid => Rcqrs::Guid.create, :name => name)
      create_from_event(event)
    end

    def change_name(new_name)
      apply(Events::CompanyNameChangedEvent.new(new_name))
    end

    def create_invoice(number, date, description, amount)
      vat = amount * 0.175
      apply(Events::InvoiceCreatedEvent.new(number, date, description, amount, vat))
    end

    private

    def on_company_created(event)
      @guid, @name = event.guid, event.name
      @invoices = []
    end

    def on_company_name_changed(event)
      @name = event.name
    end

    def on_invoice_created(event)
      @invoices << Invoice.new(event.attributes)
    end
  end
end
