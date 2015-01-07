module Rcqrs::Bus
  class EventBus
    def initialize(router)
      @router = router
    end

    # Publish event to registered handlers and projectors
    def publish(event)
      publish_to_event_handlers(event)
      publish_to_projectors(event)
    end

    private

    def publish_to_event_handlers(event)
      @router.handlers_for(event).each do |handler|
        handler.execute(event)
      end
    end

    def publish_to_projectors(event)
      Rcqrs::Projectors::Registry.projectors.each do |projector|
        projector.project(event)
      end
    end
  end
end
