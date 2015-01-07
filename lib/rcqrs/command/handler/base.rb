module Rcqrs::Command
  module Handler
    class Base
      def initialize(repository)
        @repository = repository
      end

      def execute(command)
        raise NotImplementedError, 'method to be implemented in handler'
      end
    end
  end
end
