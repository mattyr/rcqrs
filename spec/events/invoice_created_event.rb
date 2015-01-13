module Events
  class InvoiceCreatedEvent < Rcqrs::Event::Base
    attr_accessor :date, :number, :description, :gross, :vat
  end
end
