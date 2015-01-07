module Rcqrs::Bus
  class CommandBus
    def initialize(router, repository)
      @router, @repository = router, repository
    end

    # Dispatch command to registered handler
    def dispatch(command)
      raise Rcqrs::Command::InvalidCommand unless command.valid?

      handler = @router.handler_for(command, @repository)
      handler.execute(command)
    end
  end
end
