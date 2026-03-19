class CompanyVideo < ApplicationRecord
  belongs_to :company

  def code
    url.match(%r{youtube.com.*(?:/|v=)([^&$]+)})[1] rescue "0RptxXLf_FA"
  end
end
