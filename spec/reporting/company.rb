module Reporting
  class Company
    include Rcqrs::Initializer

    cattr_accessor(:instances) { [] }

    attr_reader :guid, :name

    initializer :guid, :name do
      Reporting::Company.instances << self
    end
  end
end
