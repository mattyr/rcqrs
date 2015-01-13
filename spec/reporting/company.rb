module Reporting
  class Company
    include ::ActiveModel::Model

    cattr_accessor(:instances) { [] }

    attr_accessor :guid, :name

    def initialize(attributes = {})
      super
      Reporting::Company.instances << self
    end
  end
end
