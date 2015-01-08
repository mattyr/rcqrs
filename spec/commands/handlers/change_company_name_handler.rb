module Commands
  module Handlers
    class ChangeCompanyNameHandler < Rcqrs::Command::Handler::Base
      def execute(command)
        @repository.transaction do
          company = @repository.find(command.company_id)
          company.change_name(command.name)
        end
      end
    end
  end
end
