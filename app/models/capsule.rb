class Capsule < ApplicationRecord
  belongs_to :course
  belongs_to :matter, optional: true
  has_many :lessons, dependent: :destroy

  scope :access_actives, -> { where(status: 'active') }

  private

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
