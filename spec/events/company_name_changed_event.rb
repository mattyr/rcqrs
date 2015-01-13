module Events
  class CompanyNameChangedEvent < Rcqrs::Event::Base
    attr_accessor :name
  end
end
