class SiteAdvertisement < ApplicationRecord
  has_one_attached :image

  validates :start_date, :end_date, presence: true

  scope :actives, -> { where('status = ? and start_date < ? and end_date > ?', 'active', Time.zone.now, Time.zone.now) }
  scope :initial_page, -> { where(category: 'initial_page') }
  scope :leak, -> { where(category: 'leak') }
end
