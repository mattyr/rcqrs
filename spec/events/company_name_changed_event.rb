module Events
  class CompanyNameChangedEvent < Rcqrs::Event::Base
    attr_reader :name

    initializer :name
  end
end
