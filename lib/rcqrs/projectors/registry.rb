module Projectors
  class Registry
    include Singleton

    def self.register(projector)
      instance.register(projector)
    end

    def self.projectors
      instance.projectors
    end

    attr_reader :projectors

    def register(projector_class)
      @projectors << projector_class.new
    end

    private

    def initialize
      @projectors = []
    end
  end
end
