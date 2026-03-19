class Advertisement < ApplicationRecord
  has_one_attached :image

  validates :start_date, :end_date, presence: true

  has_many :user_advertisements, dependent: :destroy

  scope :actives, -> { where('status = ? and start_date < ? and end_date > ?', 'active', Time.zone.now, Time.zone.now) }
end
