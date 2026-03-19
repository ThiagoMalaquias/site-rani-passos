class Lesson < ApplicationRecord
  has_many_attached :medias

  belongs_to :capsule

  has_many :lesson_womb_component_lectures, dependent: :destroy
  has_many :lesson_lecture_videos, dependent: :destroy
  has_many :lecture_videos, through: :lesson_lecture_videos
  has_many :lesson_content, dependent: :destroy
  has_many :lesson_completed_pdfs, dependent: :destroy
  has_many :lesson_summarized_pdfs, dependent: :destroy
  has_many :lesson_mind_maps, dependent: :destroy
  has_many :user_lessons, dependent: :destroy

  has_many :lesson_review_womb_component_lectures,  dependent: :destroy

  accepts_nested_attributes_for :lesson_content
  accepts_nested_attributes_for :lesson_completed_pdfs
  accepts_nested_attributes_for :lesson_summarized_pdfs
  accepts_nested_attributes_for :lesson_mind_maps
  accepts_nested_attributes_for :lesson_lecture_videos, allow_destroy: true, update_only: false
  accepts_nested_attributes_for :lesson_womb_component_lectures, allow_destroy: true, update_only: false, reject_if: :all_blank_or_invalid
  accepts_nested_attributes_for :lesson_review_womb_component_lectures, allow_destroy: true, update_only: false, reject_if: :all_blank_or_invalid_review
  
  before_save :correct_videos

  scope :actives, -> { where(status: 'active') }

  def released(user)
    return true if release_period.zero?

    (user_course(user, capsule).access_start + release_period.days) < Time.zone.now
  end

  def release_date(user)
    return nil if release_period.zero?

    user_course(user, capsule).access_start + release_period.days
  end

  def attended(user)
    UserLesson.find_by(user: user, lesson: self).present?
  end

  private

  def all_blank_or_invalid(attributes)
    attributes['womb_id'].blank? || attributes['component_id'].blank? || attributes['lecture_id'].blank?
  end

  def all_blank_or_invalid_review(attributes)
    attributes['womb_id'].blank? || attributes['component_id'].blank? || attributes['lecture_id'].blank? || attributes['videos'].blank?
  end

  def user_course(user, capsule)
    course = user.user_courses.find_by(course: capsule.course)
    return course if course.present?

    user.user_courses.joins(:course).find_by("courses.signature = true")
  end

  def correct_videos
    return if videos.empty?

    self.videos = videos.compact_blank
  end

  after_create do
    LogChange.save_log("Inclusão de registro (#{self.class})", atributos_log, self.class.to_s, changes.except(:updated_at))
  end

  before_update do
    LogChange.save_log("Alteração de registro (#{self.class})", atributos_log, self.class.to_s, changes.except(:updated_at))
  end

  before_destroy do
    LogChange.save_log("Exclusão de registro (#{self.class})", atributos_log, self.class.to_s, changes.except(:updated_at))
  end

  def atributos_log
    attributes.except("updated_at", "created_at")
  end
end
