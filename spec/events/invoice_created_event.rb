module Events
  class InvoiceCreatedEvent < Rcqrs::Events::DomainEvent
    attr_reader :date, :number, :description, :gross, :vat
    initializer :date, :number, :description, :gross, :vat
  end
end
