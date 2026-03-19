class Contact < ApplicationRecord
  belongs_to :company

  scope :actives, -> { where(status: 'active') }
  scope :inactives, -> { where(status: 'inactive') }

  private

  before_update do
    LogChange.save_log("Alteração de registro (#{self.class})", atributos_log, self.class.to_s, changes.except(:updated_at))
  end

  def atributos_log
    attributes.except("updated_at", "created_at")
  end
end
