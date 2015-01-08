module Rcqrs::Event
  class CommandScheduled < Base
    attr_accessor :perform_at
    attr_accessor :command_type
    attr_accessor :command_attributes

    initializer :perform_at, :command_type, :command_attributes

    def command
      command_type.constantize.new.tap{|c| c.attributes = command_attributes}
    end
  end
end
