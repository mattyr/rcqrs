module Rcqrs::Event
  module Handler
    class Base
      def execute(event)
        raise NotImplementedError, 'method to be implemented in handler'
      end
    end
  end
end
