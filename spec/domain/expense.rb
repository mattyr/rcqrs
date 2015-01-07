module Domain
  class Expense
    include Rcqrs::Initializer
    initializer :date, :description, :gross, :vat, :attr_reader => true
  end
end
