class AssessmentSubject < ApplicationRecord
  belongs_to :assessment
  has_many :grades, dependent: :destroy
end