class LessonLectureVideo < ApplicationRecord
  belongs_to :lesson
  belongs_to :lecture_video

  has_many :user_lesson_lecture_videos, dependent: :destroy
end
