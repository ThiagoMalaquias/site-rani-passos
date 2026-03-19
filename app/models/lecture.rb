class Lecture < ApplicationRecord
  belongs_to :component

  has_many :videos, class_name: :LectureVideo, dependent: :destroy
end
