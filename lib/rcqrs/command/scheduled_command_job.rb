module Rcqrs::Command
  class ScheduledCommandJob < ActiveJob::Base
    def perform(aggregate_id, command_type, command_attributes)
      command = command_type.constantize.new(command_attributes)
      Rcqrs::Gateway.publish(command)
    end
  end
end
