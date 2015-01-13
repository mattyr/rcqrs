module Commands
  class ChangeCompanyNameCommand < Rcqrs::Command::Base
    attr_reader :company_id, :name
    validates :company_id, :name, presence: true

    initializer :company_id, :name
  end
end
