module Rcqrs::Projectors
  class Registry
    include Singleton

    def self.register(klass)
      instance.register(klass)
    end

    def self.projectors
      instance.projector_classes.map{|klass| klass.new}
    end

    attr_reader :projector_classes

    def register(klass)
      @projector_classes << klass
      @projector_classes.uniq!
    end

    private

    def initialize
      @projector_classes = []
    end
  end
end
