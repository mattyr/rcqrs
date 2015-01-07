module Rcqrs::Commands
  module ActiveModel
    extend ActiveSupport::Concern

    included do
      include ::ActiveModel::Conversion
      include ::ActiveModel::AttributeMethods
      include ::ActiveModel::Validations
      include ::Wisper::Publisher

      include ::Rcqrs::Initializer
      include ::Rcqrs::Commands::ActiveModel

      extend ::ActiveModel::Naming
    end

    # Commands are never persisted
    def persisted?
      false
    end

    def broadcast_domain_event(event)
      # broadcast a generic event
      broadcast(:domain_event, event)
      # and also a specific one (makes for easier one-off listeners)
      broadcast(event.class.target_name(false).to_sym, event)
    end
  end
end
