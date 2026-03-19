class Matter < ApplicationRecord
  belongs_to :instructor
  belongs_to :course

  has_many :capsules, dependent: :destroy

  after_update :set_date_access_period, if: -> { saved_change_to_access_period_type? }

  scope :active, -> { where(status: 'active') }

  def set_date_access_period
    self.date_access_period = nil if access_period_type == "all"
    self.date_access_period = Date.today if access_period_type != "all"
    save
  end

  def progressive(user)
    return 0 if capsules.blank?
    
    total_lessons = 0
    total_user_lessons = 0
    
    capsules.each do |capsule|
      total_lessons += capsule.lessons.count
      total_user_lessons += UserLesson.where(user: user, lesson: capsule.lessons).count
    end
    
    return 0 if total_lessons.zero?
    
    ((total_user_lessons * 100) / total_lessons).to_i
  rescue
    0
  end
end
