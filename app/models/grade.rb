class Grade < ApplicationRecord
  belongs_to :participation
  belongs_to :assessment_subject
end