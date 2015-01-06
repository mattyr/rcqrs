module Commands
  module ActiveModel
    def self.extended(base)
      base.class_eval do
        include ::ActiveModel::Conversion
        include ::ActiveModel::AttributeMethods
        include ::ActiveModel::Validations
        extend ::ActiveModel::Naming
        include Wisper::Publisher

        extend ::Rcqrs::Initializer
        include Commands::ActiveModel
      end
    end

    # Commands are never persisted
    def persisted?
      false
    end

    def broadcast_domain_event(event)
      broadcast(:domain_event, event)
    end
  end
end
