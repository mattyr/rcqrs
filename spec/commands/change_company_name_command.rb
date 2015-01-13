module Commands
  class ChangeCompanyNameCommand < Rcqrs::Command::Base
    attr_accessor :company_id, :name
    validates :company_id, :name, presence: true
  end
end
