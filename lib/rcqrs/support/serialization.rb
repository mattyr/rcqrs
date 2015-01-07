module Rcqrs
  module Serialization
    extend ActiveSupport::Concern

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
