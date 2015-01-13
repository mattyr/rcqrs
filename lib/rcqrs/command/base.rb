module Rcqrs::Command
  class Base
    include ::ActiveModel::Model
    include ::Wisper::Publisher

    def attributes=(hash)
      hash.each do |key, value|
        send("#{key}=", value)
      end
    end

    def attributes
      instance_values
    end

    def initialize(attributes = {})
      super
      self.attributes = attributes
    end

    def broadcast_domain_event(event)
      # broadcast a generic event
      broadcast(:domain_event, event)
      # and also a specific one (makes for easier one-off listeners)
      broadcast(event.class.target_name(false).to_sym, event)
    end
  end
end
