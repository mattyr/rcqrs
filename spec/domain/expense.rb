module Domain
  class Expense
    include ::ActiveModel::Model

    attr_accessor :date, :description, :gross, :vat
  end
end
