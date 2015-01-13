module Domain
  class Invoice
    include ::ActiveModel::Model

    attr_accessor :number, :date, :description, :gross, :vat
  end
end
