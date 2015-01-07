module Domain
  class Invoice
    include Rcqrs::Initializer
    initializer :number, :date, :description, :gross, :vat, :attr_reader => true
  end
end
