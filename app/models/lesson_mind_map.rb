class LessonMindMap < ApplicationRecord
  belongs_to :lesson
  has_one_attached :midia

end
