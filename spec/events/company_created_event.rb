module Events
  class CompanyCreatedEvent < Rcqrs::Events::DomainEvent
    attr_reader :guid, :name

    initializer :guid, :name
  end
end
