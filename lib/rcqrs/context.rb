module Rcqrs
  class Context
    def self.current
      Thread.current['Rcqrs::Context.current'] ||=
        Rcqrs::Context.new
    end

    attr_accessor :command

    def clear
      self.command = nil
    end
  end
end
