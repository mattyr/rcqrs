# imported from https://github.com/slashdotdash/rcqrs-rails/blob/master/lib/rcqrs/gateway.rb
module Rcqrs
  class Gateway
    include ActiveSupport::Configurable
    include Singleton

    # this seems to be only useful for testing
    def self.reinitialize
      instance.reinitialize
    end

    def self.publish(command)
      instance.dispatch(command)
    end

    # publish_at, except now
    def self.publish_async(aggregate_id, command)
      publish_at(aggregate_id, command, nil)
    end

    def self.publish_at(aggregate_id, command, at)
      repository.transaction do
        aggregate = repository.find(aggregate_id)

        job = Rcqrs::Command::ScheduledCommandJob
        if !at.nil?
          job = job.set(wait_until: at)
        end

        job.perform_later(aggregate_id, command.class.name, command.attributes)

        if !at.nil?
          aggregate.command_scheduled(command, at)
        end
      end
    end

    def self.repository
      instance.repository
    end

    def self.command_bus
      instance.command_bus
    end

    def self.event_bus
      instance.event_bus
    end

    attr_reader :repository, :command_bus, :event_bus

    # Dispatch commands to the bus within a transaction
    def dispatch(command)
      Rcqrs::Context.current.command = command
      begin
        @repository.transaction do
          @command_bus.dispatch(command)
        end
      ensure
        Rcqrs::Context.current.clear
      end
    end

    def reinitialize
      @repository = create_repository
      @command_bus = create_command_bus
      @event_bus = create_event_bus

      # TODO: do we get leakage after multiple calls here?
      wire_events
    end

    private

    def initialize
      reinitialize
    end

    # Dispatch raised domain events
    # TODO: this should not rely on Wisper, but rather be handled
    # by some kind of core coordination object
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
      config.event_store_adapter || EventStore::Adapters::InMemoryAdapter.new
    end
  end
end
