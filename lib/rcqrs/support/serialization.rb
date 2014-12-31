module Rcqrs
  module Serialization
    def self.included(base)
      base.extend ClassMethods
    end

    def to_json(attributes=self.attributes)
      ActiveSupport::JSON.encode(attributes)
    end

    module ClassMethods
      def from_json(json)
        parsed = ActiveSupport::JSON.decode(json)
        self.new(parsed)
      end
    end
  end
end
