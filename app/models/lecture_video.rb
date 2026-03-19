class LectureVideo < ApplicationRecord
  belongs_to :lecture
  
  has_many :lesson_lecture_videos, dependent: :destroy
end
