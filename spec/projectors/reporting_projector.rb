module Projectors
  class ReportingProjector
    include Rcqrs::Projectors::Projector

    def on_company_created(event)
      ::Reporting::Company.new(guid: event.guid, name: event.name)
    end
  end
end
