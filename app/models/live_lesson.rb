class LiveLesson < ApplicationRecord
  belongs_to :company
  has_one_attached :material, service: :amazon
  has_many :leads, dependent: :destroy

  after_save :verify_slug

  scope :actives, -> { where(status: 'active') }
  scope :current_month, -> { where("TO_CHAR(start_date,'YYYY-MM-DD') >= ? and TO_CHAR(end_date,'YYYY-MM-DD') <= ?", Date.current.beginning_of_month, Date.current.end_of_month) }

  def moment
    return 'online' if start_date < Time.zone.now && end_date > Time.zone.now
    return 'pending' if start_date > Time.zone.now

    'completed'
  end

  private

  def verify_slug
    return if slug.present?

    self.slug = "#{title.parameterize}-#{id}"
    save
  end
end
