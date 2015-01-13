module Rcqrs::Event
  class Base
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    attr_accessor :aggregate_id, :version, :timestamp

    def attributes=(hash)
      hash.each do |key, value|
        send("#{key}=", value)
      end
    end

    def attributes
      instance_values.with_indifferent_access.except(:aggregate_id, :version, :timestamp)
    end

    def initialize(attributes = {})
      super
      self.attributes = attributes
    end

    # used to determine target method names for handlers/etc
    def self.target_name(demodulize = true)
      target = name.to_s
      target = target.demodulize if demodulize
      target.gsub(/::/, '_').underscore.gsub(/_event$/, '')
    end
  end
end
