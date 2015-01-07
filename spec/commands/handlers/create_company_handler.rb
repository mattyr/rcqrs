module Commands
  module Handlers
    class CreateCompanyHandler < Rcqrs::Commands::Handlers::BaseHandler
      def execute(command)
        company = Domain::Company.create(command.name)
        @repository.save(company)
      end
    end
  end
end
