module Commands
  class CreateCompanyCommand
    extend Rcqrs::Commands::ActiveModel

    attr_reader :name
    validates_presence_of :name

    initializer :name
  end
end
