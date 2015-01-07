module Events
  class InvoiceCreatedEvent < Rcqrs::Event::Base
    attr_reader :date, :number, :description, :gross, :vat
    initializer :date, :number, :description, :gross, :vat
  end
end
