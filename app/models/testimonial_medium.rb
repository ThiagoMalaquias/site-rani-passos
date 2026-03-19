class TestimonialMedium < ApplicationRecord
  belongs_to :company
  has_one_attached :banner

  def code
    url.match(%r{youtube.com.*(?:/|v=)([^&$]+)})[1] rescue "0RptxXLf_FA"
  end
end
