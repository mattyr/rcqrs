module Projectors
  module Projector
    def self.included(base)
      Projectors::Registry.register(base)
    end

    def project(event)
      if respond_to?(handler_method_name_for(event.class))
        send(handler_method_name_for(event.class), event)
      end
    end

    private

    def handler_method_names
      @handler_method_namess ||= {}
    end

    def handler_method_name_for(event_class)
      handler_method_names[event_class] ||=
        "on_#{normalized_handler_name(event_class)}".to_sym
    end

    def normalized_handler_name(klass)
      klass.name.
        gsub(/Event$/, '').
        gsub(/^Events::/, '').
        gsub(/::/, '').underscore
    end
  end
end
