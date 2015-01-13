module Events
  class CompanyCreatedEvent < Rcqrs::Event::Base
    attr_accessor :guid, :name
  end
end
