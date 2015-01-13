module Events
  class CompanyCreatedEvent < Rcqrs::Event::Base
    attr_reader :guid, :name

    initializer :guid, :name
  end
end
