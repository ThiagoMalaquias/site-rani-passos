class CourseFreeLink < ApplicationRecord
  belongs_to :course
  belongs_to :tag, optional: true
  has_many :free_link_user_courses, dependent: :destroy
  has_many :free_link_accesses, dependent: :destroy
  
  def self.generate_codes
    code = ''
    subcode = ''

    loop do
      fullcode = SecureRandom.urlsafe_base64(12)
      code = fullcode.slice(0, 8)
      subcode = fullcode.slice(8, 12)
      break if exists?(code: code, subcode: subcode).blank?
    end

    [code, subcode]
  end

  private

  after_create do
    LogChange.save_log("Inclusão de registro (#{self.class})", atributos_log, self.class.to_s, changes.except(:updated_at))
  end

  before_destroy do
    LogChange.save_log("Exclusão de registro (#{self.class})", atributos_log, self.class.to_s, changes.except(:updated_at))
  end

  def atributos_log
    attributes.except("updated_at", "created_at")
  end
end
