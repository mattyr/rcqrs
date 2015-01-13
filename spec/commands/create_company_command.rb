module Commands
  class CreateCompanyCommand < Rcqrs::Command::Base
    attr_accessor :name
    validates_presence_of :name
  end
end
