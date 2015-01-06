module Projectors
  class ReportingProjector
    include Projectors::Projector

    def on_company_created(event)
      ::Reporting::Company.new(event.guid, event.name)
    end
  end
end