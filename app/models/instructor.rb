class Instructor < ApplicationRecord
  has_one_attached :photo
  has_one_attached :avatar

  scope :disclosure_actives, -> { where(disclosure: true) }
end
