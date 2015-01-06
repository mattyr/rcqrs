module Events
  class DomainEvent
    extend Rcqrs::Initializer
    include Rcqrs::Serialization

    attr_accessor :aggregate_id, :version, :timestamp

    # used to determine target method names for handlers/etc
    def self.target_name(demodulize = true)
      target = name.to_s
      target = target.demodulize if demodulize
      target.underscore.gsub(/_event$/, '')
    end
  end
end
