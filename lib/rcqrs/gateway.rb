# imported from https://github.com/slashdotdash/rcqrs-rails/blob/master/lib/rcqrs/gateway.rb
module Rcqrs
  class Gateway
    include ActiveSupport::Configurable
    include Singleton

    def self.publish(command)
      instance.dispatch(command)
    end

    attr_reader :repository, :command_bus, :event_bus

    # Dispatch commands to the bus within a transaction
    def dispatch(command)
      @repository.transaction do
        @command_bus.dispatch(command)
      end
    end

    private

    def initialize
      @repository = create_repository
      @command_bus = create_command_bus
      @event_bus = create_event_bus

      wire_events
    end

    # Dispatch raised domain events
    def wire_events
      @repository.on(:domain_event) {|event| @event_bus.publish(event) }
    end

    def create_repository
      EventStore::DomainRepository.new(create_event_storage)
    end

    def create_command_bus
      Bus::CommandBus.new(Bus::CommandRouter.new, @repository)
    end

    def create_event_bus
      Bus::EventBus.new(Bus::EventRouter.new)
    end

    def create_event_storage
      config.event_store_adapter || EventStore::Adapters::InMemoryAdapter
    end
  end
end
