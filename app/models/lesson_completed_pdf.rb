class LessonCompletedPdf < ApplicationRecord
  belongs_to :lesson
  has_one_attached :midia
end
