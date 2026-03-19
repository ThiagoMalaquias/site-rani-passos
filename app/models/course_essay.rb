class CourseEssay < ApplicationRecord
  has_one_attached :material

  belongs_to :course
  belongs_to :capsule
  belongs_to :sent, polymorphic: true
  belongs_to :received, polymorphic: true

  after_create :update_viewed, if: -> { sent_type == 'Teacher' }

  private

  def update_viewed
    CourseEssay.where(sent_id: sent_id, sent_type: 'User').update_all(viewed: true)
  end
end
