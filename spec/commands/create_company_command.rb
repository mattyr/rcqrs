module Commands
  class CreateCompanyCommand < Rcqrs::Command::Base
    attr_reader :name
    validates_presence_of :name

    initializer :name
  end
end
