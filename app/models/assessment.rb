class Assessment < ApplicationRecord
  has_one_attached :file
  has_one_attached :file_answer_comments

  belongs_to :tag, optional: true
  
  has_many :assessment_subjects, dependent: :destroy
  has_many :participations, dependent: :destroy
  has_many :participants, through: :participations, source: :user

  after_commit :verify_slug, on: [:create, :update]
  
  accepts_nested_attributes_for :assessment_subjects, allow_destroy: true

  private

  def verify_slug
    return if slug.present?

    self.slug = "#{title.parameterize}-#{id}"
    save
  end
end
