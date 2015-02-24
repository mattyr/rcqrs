module Rcqrs::EventStore
  class AggregateNotFound < StandardError; end
  class AggregateConcurrencyError < StandardError; end
  class UnknownAggregateClass < StandardError; end

  class DomainRepository
    include Wisper::Publisher

    attr_reader :event_store

    def initialize(event_store)
      @event_store = event_store
      @tracked_aggregates = {}
      @committed_events = []
      @transaction_stack_level = 0
    end

    # Persist the +aggregate+ to the event store
    def save(aggregate)
      transaction { track(aggregate) }
    end

    # Find an aggregate by the given +guid+
    # Track any changes to the returned aggregate, commiting those changes when saving aggregates
    #
    # == Exceptions
    #
    # * AggregateNotFound - No aggregate for the given +guid+ was found
    # * UnknownAggregateClass - The type of aggregate is unknown
    def find(guid)
      return @tracked_aggregates[guid] if @tracked_aggregates.has_key?(guid)

      provider = @event_store.find(guid)
      raise AggregateNotFound if provider.nil?

      load_aggregate(provider.aggregate_type, provider.events)
    end

    # pushes all events for the aggregate with the given guid to projectors
    def reproject!(guid)
      provider = @event_store.find(guid)

      raise AggregateNotFound if provider.nil?

      provider.events.map{|event| create_event(event)}.sort_by{|e| e.version}.each do |event|
        Rcqrs::Projectors::Registry.projectors.each do |projector|
          projector.reproject(event)
        end
      end
    end

    # Save changes to the event store within a transaction
    def transaction(&block)
      @transaction_stack_level += 1

      if @transaction_stack_level > 1
        yield
      else
        @event_store.transaction do
          yield
          persist_aggregates_to_event_store
        end
        broadcast_committed_events
      end

    rescue
      @tracked_aggregates.clear # abandon changes on exception
      @committed_events.clear
      raise
    ensure
      @transaction_stack_level -= 1
    end

    def within_transaction?
      @transaction_stack_level > 0
    end

  private

    # Track changes to this aggregate root so that any unsaved events
    # are persisted when save is called (for any aggregate)
    def track(aggregate)
      @tracked_aggregates[aggregate.guid] = aggregate
    end

    def persist_aggregates_to_event_store
      committed_events = []

      @tracked_aggregates.each do |guid, tracked|
        next unless tracked.pending_events?

        @event_store.save(tracked)
        committed_events += tracked.pending_events
        tracked.commit
      end

      @committed_events += committed_events.sort_by(&:timestamp)
    end

    def broadcast_committed_events
      @committed_events.each do |event|
        broadcast(:domain_event, event)
        # if there's a command context, broadcast through that as well
        if !Rcqrs::Context.current.command.nil?
          Rcqrs::Context.current.command.broadcast_domain_event(event)
        end
      end
      @committed_events.clear
    end

    # Get unsaved events for all tracked aggregates, ordered by time applied
    # def pending_events
    #   @tracked_aggregates.map {|guid, tracked| tracked.pending_events }.flatten!.sort_by(&:timestamp)
    # end

    # Recreate an aggregate root by re-applying all saved +events+
    def load_aggregate(klass, events)
      create_aggregate(klass).tap do |aggregate|
        events.map! {|event| create_event(event) }
        aggregate.load(events)
        track(aggregate)
      end
    end

    # Create a new instance an aggregate from the given +events+
    def create_aggregate(klass)
      klass.constantize.new
    end

    # Create a new instance of the domain event from the serialized json
    def create_event(event)
      event.event_type.constantize.new.from_json(event.data).tap do |domain_event|
        domain_event.version = event.version.to_i
        domain_event.aggregate_id = event.aggregate_id.to_s
      end
    end
  end
end
